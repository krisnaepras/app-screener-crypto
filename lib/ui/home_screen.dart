import 'package:flutter/material.dart';
import '../models/coin_data.dart';
import '../logic/screener_logic.dart';
import 'coin_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScreenerLogic _logic = ScreenerLogic();
  Stream<List<CoinData>>? _stream;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _stream = _logic.coinStream;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _logic.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() => _isRefreshing = true);
    _logic.dispose();
    _logic = ScreenerLogic();
    _stream = _logic.coinStream;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isRefreshing = false);
    });
  }

  List<CoinData> _filterCoins(List<CoinData> coins) {
    // First filter to only show TRIGGER, SETUP, WATCH status
    var validCoins = coins
        .where(
          (c) =>
              c.status == 'TRIGGER' ||
              c.status == 'SETUP' ||
              c.status == 'WATCH',
        )
        .toList();

    if (_searchQuery.isEmpty) return validCoins;
    return validCoins
        .where(
          (coin) =>
              coin.symbol.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'TRIGGER':
        return Colors.redAccent;
      case 'SETUP':
        return Colors.orangeAccent;
      case 'WATCH':
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }

  Color _getConfluenceColor(int count) {
    if (count >= 2) return Colors.green;
    if (count >= 1) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search coin...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _isRefreshing ? null : _refresh,
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<CoinData>>(
            stream: _stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final allCoins = snapshot.data ?? [];
              final coins = _filterCoins(allCoins);
              if (coins.isEmpty) {
                return const Center(
                  child: Text('No Data / Waiting for Backend...'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                itemCount: coins.length,
                itemBuilder: (context, index) {
                  final coin = coins[index];
                  final statusColor = _getStatusColor(coin.status);

                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CoinDetailScreen(coin: coin),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    coin.status.isNotEmpty
                                        ? coin.status[0]
                                        : '?',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              coin.symbol.replaceAll(
                                                'USDT',
                                                '',
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              'Score ${coin.score.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text(
                                            coin.status,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            '${coin.priceChangePercent.toStringAsFixed(2)}%',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  coin.priceChangePercent >= 0
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                          if (coin.triggerTf != null &&
                                              coin.triggerTf!.isNotEmpty) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.purple,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                coin.triggerTf!.toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                          if (coin.confluenceCount > 0) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _getConfluenceColor(
                                                  coin.confluenceCount,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '${coin.confluenceCount}TF',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '\$${coin.price > 1 ? coin.price.toStringAsFixed(2) : coin.price.toStringAsFixed(5)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            if (coin.features != null) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  if (coin.features!.isBreakdown)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'BREAK',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  if (coin.features!.isRetest)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'RETEST',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  if (coin.features!.rsi > 70)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade700,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'RSI${coin.features!.rsi.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  if (coin.features!.overExtEma > 0.03)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade800,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'EXT',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  if (coin.basisSpread > 1.0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade600,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'BASIS',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  if (coin.fundingRate > 0.01)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'FUND',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

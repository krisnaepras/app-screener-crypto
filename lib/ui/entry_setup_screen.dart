import 'package:flutter/material.dart';
import '../models/coin_data.dart';
import '../logic/screener_logic.dart';
import '../services/trade_service.dart';
import 'coin_detail_screen.dart';

class EntrySetupScreen extends StatefulWidget {
  const EntrySetupScreen({super.key});

  @override
  State<EntrySetupScreen> createState() => _EntrySetupScreenState();
}

class _EntrySetupScreenState extends State<EntrySetupScreen> {
  final ScreenerLogic _logic = ScreenerLogic();
  Stream<List<CoinData>>? _stream;

  @override
  void initState() {
    super.initState();
    _stream = _logic.coinStream;
  }

  @override
  void dispose() {
    _logic.dispose();
    super.dispose();
  }

  /// Filter coins that are TRIGGER or SETUP (ready for entry)
  /// Focus on 1m timeframe signals for precise entries
  List<CoinData> _getEntryReadyCoins(List<CoinData> coins) {
    return coins
        .where((c) => c.status == 'TRIGGER' || c.status == 'SETUP')
        .where((c) {
          // Prioritize coins with 1m timeframe showing signals
          final has1mScore = c.tfScores.any(
            (ts) => ts.tf == '1m' && ts.score >= 30,
          );
          return has1mScore;
        })
        .toList()
      ..sort((a, b) {
        // Sort by 1m score first, then total score
        final a1m = a.tfScores
            .firstWhere(
              (ts) => ts.tf == '1m',
              orElse: () => TimeframeScore(tf: '1m', score: 0),
            )
            .score;
        final b1m = b.tfScores
            .firstWhere(
              (ts) => ts.tf == '1m',
              orElse: () => TimeframeScore(tf: '1m', score: 0),
            )
            .score;
        if (b1m != a1m) return b1m.compareTo(a1m);
        return b.score.compareTo(a.score);
      });
  }

  /// Get 1m specific data for a coin
  double _get1mScore(CoinData coin) {
    return coin.tfScores
        .firstWhere(
          (ts) => ts.tf == '1m',
          orElse: () => TimeframeScore(tf: '1m', score: 0),
        )
        .score;
  }

  double _get1mRsi(CoinData coin) {
    return coin.tfScores
        .firstWhere(
          (ts) => ts.tf == '1m',
          orElse: () => TimeframeScore(tf: '1m', score: 0, rsi: 50),
        )
        .rsi;
  }

  Color _getConfluenceColor(int count) {
    if (count >= 2) return Colors.green;
    if (count >= 1) return Colors.orange;
    return Colors.grey;
  }

  void _showEntryDialog(CoinData coin) {
    final entryPrice = coin.price;
    final sl = entryPrice * 1.006;
    final tp1 = entryPrice * 0.992;
    final tp2 = entryPrice * 0.985;
    final tp3 = entryPrice * 0.975;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.trending_down, color: Colors.red),
            const SizedBox(width: 8),
            Text('SHORT ${coin.symbol.replaceAll('USDT', '')}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${coin.confluenceCount}TF Confluence | Score ${coin.score.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildLevelRow('Entry', entryPrice),
              _buildLevelRow('SL', sl, isLoss: true),
              _buildLevelRow('TP1', tp1),
              _buildLevelRow('TP2', tp2),
              _buildLevelRow('TP3', tp3),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'R:R = 0.6% : 0.8% / 1.5% / 2.5%',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _submitEntry(coin, entryPrice, sl, tp1, tp2, tp3);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm SHORT'),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelRow(String label, double price, {bool isLoss = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isLoss ? Colors.red : Colors.green,
            ),
          ),
          Text('\$${price.toStringAsFixed(4)}'),
        ],
      ),
    );
  }

  Future<void> _submitEntry(
    CoinData coin,
    double entryPrice,
    double sl,
    double tp1,
    double tp2,
    double tp3,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final reason =
          '${coin.confluenceCount}TF | Score: ${coin.score.toStringAsFixed(0)} | RSI: ${coin.features?.rsi.toStringAsFixed(0) ?? '-'}';
      await TradeService.createEntry(
        symbol: coin.symbol,
        isLong: false,
        entryPrice: entryPrice,
        stopLoss: sl,
        takeProfit1: tp1,
        takeProfit2: tp2,
        takeProfit3: tp3,
        entryReason: reason,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Entry ${coin.symbol} created'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CoinData>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allCoins = snapshot.data ?? [];
        final readyCoins = _getEntryReadyCoins(allCoins);

        if (readyCoins.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hourglass_empty,
                  size: 64,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(height: 16),
                Text(
                  'Waiting for entries...',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 8),
                Text(
                  'Looking for 1m + 5m confluence entries',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Focus: 1m timeframe signals',
                  style: TextStyle(fontSize: 12, color: Colors.purple.shade300),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${allCoins.length} coins streaming • ${allCoins.where((c) => c.status == 'WATCH').length} watching',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: readyCoins.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      '${readyCoins.length} Entry Ready',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '1m Focus',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final coin = readyCoins[index - 1];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CoinDetailScreen(coin: coin),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // 1m Focus Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '1m: ${_get1mScore(coin).toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getConfluenceColor(coin.confluenceCount),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${coin.confluenceCount}TF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              coin.symbol.replaceAll('USDT', ''),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${coin.price > 1 ? coin.price.toStringAsFixed(2) : coin.price.toStringAsFixed(5)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${coin.priceChangePercent >= 0 ? '+' : ''}${coin.priceChangePercent.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: coin.priceChangePercent >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Momentum and Signal Info Row
                      Row(
                        children: [
                          _buildChip(
                            'RSI ${_get1mRsi(coin).toStringAsFixed(0)}',
                            _get1mRsi(coin) > 70
                                ? Colors.red
                                : _get1mRsi(coin) > 60
                                ? Colors.orange
                                : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          if (coin.features != null &&
                              coin.features!.isLosingMomentum)
                            _buildChip('⚡ Loss Mom', Colors.purple),
                          if (coin.features != null &&
                              coin.features!.hasRsiDivergence) ...[
                            const SizedBox(width: 6),
                            _buildChip('📉 RSI Div', Colors.orange),
                          ],
                          if (coin.features != null &&
                              coin.features!.hasVolumeDivergence) ...[
                            const SizedBox(width: 6),
                            _buildChip('📊 Vol Div', Colors.blue),
                          ],
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () => _showEntryDialog(coin),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            icon: const Icon(Icons.trending_down, size: 18),
                            label: const Text('SHORT'),
                          ),
                        ],
                      ),
                      // TF Score bars - Highlight 1m
                      if (coin.tfScores.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: coin.tfScores.map((ts) {
                            final is1m = ts.tf == '1m';
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: is1m
                                      ? Colors.purple.withOpacity(0.2)
                                      : ts.score >= 50
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: is1m
                                      ? Border.all(
                                          color: Colors.purple,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      ts.tf.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: is1m
                                            ? Colors.purple
                                            : Colors.white70,
                                      ),
                                    ),
                                    Text(
                                      ts.score.toStringAsFixed(0),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: is1m ? 16 : 14,
                                        color: is1m
                                            ? Colors.purple
                                            : ts.score >= 50
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'RSI ${ts.rsi.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: ts.rsi > 70
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
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
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../models/coin_data.dart';
import '../logic/screener_logic.dart';
import 'coin_detail_screen.dart';

class RsiScreen extends StatefulWidget {
  const RsiScreen({super.key});

  @override
  State<RsiScreen> createState() => _RsiScreenState();
}

class _RsiScreenState extends State<RsiScreen> {
  final ScreenerLogic _logic = ScreenerLogic();
  List<CoinData>? _coins;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Listen to background service updates
    FlutterBackgroundService().on('update').listen((event) {
      if (event != null && event['data'] != null) {
        final List<dynamic> list = event['data'] as List<dynamic>;
        if (mounted) {
          setState(() {
            _coins = list
                .map(
                  (json) => CoinData.fromJson(Map<String, dynamic>.from(json)),
                )
                .toList();
            _filterRsiCoins();
            _isLoading = false;
          });
        }
      }
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final coins = await _logic.scan();
      if (mounted) {
        setState(() {
          _coins = coins;
          _filterRsiCoins();
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterRsiCoins() {
    if (_coins == null) return;

    // Filter untuk RSI >= 60 atau RSI <= 40
    _coins = _coins!.where((coin) {
      if (coin.features == null) return false;
      return coin.features!.rsi >= 60 || coin.features!.rsi <= 40;
    }).toList();

    // Sort by RSI extremes (highest and lowest first)
    _coins!.sort((a, b) {
      final aExtreme = (a.features!.rsi - 50).abs();
      final bExtreme = (b.features!.rsi - 50).abs();
      return bExtreme.compareTo(aExtreme);
    });
  }

  String _getReversalSignal(CoinData coin) {
    final features = coin.features!;
    final rsi = features.rsi;

    if (rsi > 70) {
      // Overbought - looking for SHORT entry
      int confirmationCount = 0;
      List<String> signals = [];

      if (features.isBreakdown) {
        confirmationCount++;
        signals.add('Breakdown');
      }
      if (features.overExtEma > 0.05) {
        confirmationCount++;
        signals.add('EMA Overext');
      }
      if (features.isAboveUpperBand) {
        confirmationCount++;
        signals.add('Above BB');
      }
      if (coin.basisSpread > 1.5) {
        confirmationCount++;
        signals.add('High Basis');
      }

      if (confirmationCount >= 3) {
        return '🔴 READY SHORT (${signals.take(3).join(', ')})';
      } else if (confirmationCount >= 2) {
        return '🟠 WAIT CONFIRM (${signals.join(', ')})';
      } else if (confirmationCount >= 1) {
        return '🟡 WATCH (${signals.join(', ')})';
      } else {
        return '⚪ RSI HIGH - Wait signals';
      }
    } else if (rsi < 30) {
      // Oversold - looking for LONG entry
      int confirmationCount = 0;
      List<String> signals = [];

      if (features.isRetest && !features.isRetestFail) {
        confirmationCount++;
        signals.add('Retest Support');
      }
      if (features.overExtEma < -0.03) {
        confirmationCount++;
        signals.add('Below EMA');
      }
      if (features.nearestSupport != null &&
          features.distToSupportATR != null) {
        if (features.distToSupportATR!.abs() < 2) {
          confirmationCount++;
          signals.add('Near Support');
        }
      }

      if (confirmationCount >= 2) {
        return '🟢 READY LONG (${signals.join(', ')})';
      } else if (confirmationCount >= 1) {
        return '🟡 WATCH LONG (${signals.join(', ')})';
      } else {
        return '⚪ RSI LOW - Wait signals';
      }
    } else if (rsi >= 60) {
      return '🟡 RSI Elevated - Monitor';
    } else {
      return '🔵 RSI Declining - Monitor';
    }
  }

  Color _getSignalColor(String signal) {
    if (signal.startsWith('🔴')) return Colors.red;
    if (signal.startsWith('🟢')) return Colors.green;
    if (signal.startsWith('🟠')) return Colors.orange;
    if (signal.startsWith('🟡')) return Colors.yellow;
    if (signal.startsWith('🔵')) return Colors.blue;
    return Colors.grey;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RSI Screening'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Column(
        children: [
          // Info Card
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📊 RSI Reversal Screening',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Monitoring coin dengan RSI ekstrim (>60 atau <40) dan konfirmasi reversal',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _coins == null || _coins!.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No RSI signals / Error'),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _coins!.length,
                    itemBuilder: (context, index) {
                      final coin = _coins![index];
                      final features = coin.features!;
                      final reversalSignal = _getReversalSignal(coin);
                      final signalColor = _getSignalColor(reversalSignal);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CoinDetailScreen(coin: coin),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // RSI Badge
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: features.rsi > 70
                                            ? Colors.red
                                            : features.rsi < 30
                                            ? Colors.green
                                            : features.rsi >= 60
                                            ? Colors.orange
                                            : Colors.blue,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          const Text(
                                            'RSI',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            features.rsi.toStringAsFixed(0),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Coin Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            coin.symbol.replaceAll('USDT', ''),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            '\$${coin.price > 1 ? coin.price.toStringAsFixed(2) : coin.price.toStringAsFixed(5)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            '${coin.priceChangePercent.toStringAsFixed(2)}%',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  coin.priceChangePercent >= 0
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Score
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Score',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        Text(
                                          coin.score.toStringAsFixed(0),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Reversal Signal
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: signalColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: signalColor.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Text(
                                    reversalSignal,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: signalColor,
                                    ),
                                  ),
                                ),

                                // Additional indicators
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: [
                                    if (features.isBreakdown)
                                      _buildBadge('BREAK', Colors.red),
                                    if (features.isRetest)
                                      _buildBadge('RETEST', Colors.blue),
                                    if (features.overExtEma.abs() > 0.05)
                                      _buildBadge(
                                        'EMA ${(features.overExtEma * 100).toStringAsFixed(1)}%',
                                        features.overExtEma > 0
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    if (features.isAboveUpperBand)
                                      _buildBadge('ABOVE BB', Colors.orange),
                                    if (coin.basisSpread > 1.0)
                                      _buildBadge(
                                        'BASIS ${coin.basisSpread.toStringAsFixed(1)}%',
                                        Colors.red,
                                      ),
                                    if (features.nearestSupport != null)
                                      _buildBadge(
                                        'SUP \$${features.nearestSupport!.toStringAsFixed(2)}',
                                        Colors.blue.shade700,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

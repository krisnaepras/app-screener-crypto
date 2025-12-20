import 'package:flutter/material.dart';
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

  List<CoinData> _filterRsiCoins(List<CoinData> coins) {
    // Filter untuk RSI >= 60 atau RSI <= 40
    final filtered = coins.where((coin) {
      if (coin.features == null) return false;
      return coin.features!.rsi >= 60 || coin.features!.rsi <= 40;
    }).toList();

    // Sort by RSI extremes (highest and lowest first)
    filtered.sort((a, b) {
      final aExtreme = (a.features!.rsi - 50).abs();
      final bExtreme = (b.features!.rsi - 50).abs();
      return bExtreme.compareTo(aExtreme);
    });

    return filtered;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RSI Reversal (Realtime)')),
      body: Column(
        children: [
          // Info Card
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔄 RSI Reversal Timing',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Overbought (60-70+): Siap SHORT | Oversold (30-40): Siap LONG',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
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
                final coins = _filterRsiCoins(allCoins);

                if (coins.isEmpty) {
                  return const Center(child: Text('No RSI signals'));
                }

                return ListView.builder(
                  itemCount: coins.length,
                  itemBuilder: (context, index) {
                    final coin = coins[index];
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
                                            color: coin.priceChangePercent >= 0
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Score
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
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

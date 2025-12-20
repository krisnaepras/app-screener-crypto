import 'package:flutter/material.dart';
import '../models/coin_data.dart';
import '../logic/screener_logic.dart';
import 'coin_detail_screen.dart';

class ScalpingScreen extends StatefulWidget {
  const ScalpingScreen({super.key});

  @override
  State<ScalpingScreen> createState() => _ScalpingScreenState();
}

class _ScalpingScreenState extends State<ScalpingScreen> {
  final ScreenerLogic _logic = ScreenerLogic();
  Stream<List<CoinData>>? _stream;

  @override
  void initState() {
    super.initState();
    _stream = _logic.coinStream;
  }

  List<CoinData> _filterScalpingCoins(List<CoinData> coins) {
     if (coins.isEmpty) return [];

    // Filter untuk scalping: high volume, momentum, dan setup yang jelas
    final filtered = coins.where((coin) {
      if (coin.features == null) return false;

      final features = coin.features!;

      // 1. Volume harus tinggi (sudah difilter di screener dengan 50M+)
      // 2. RSI harus di range scalping (35-65) - tidak terlalu ekstrim
      // 3. Ada momentum atau setup struktur
      final rsiInRange = features.rsi >= 35 && features.rsi <= 65;
      final hasSetup =
          features.isRetest ||
          features.isBreakdown ||
          features.overExtEma.abs() > 0.02;

      return rsiInRange && hasSetup;
    }).toList();

    // Sort by scalping score
    filtered.sort((a, b) {
      final aScore = _calculateScalpingScore(a);
      final bScore = _calculateScalpingScore(b);
      return bScore.compareTo(aScore);
    });
    
    return filtered;
  }

  double _calculateScalpingScore(CoinData coin) {
    if (coin.features == null) return 0;
    final features = coin.features!;
    double score = 0;

    // Momentum (40 points)
    final momentum = coin.priceChangePercent.abs();
    if (momentum >= 3 && momentum <= 8) {
      score += 20; // Sweet spot untuk scalping
    } else if (momentum > 1 && momentum < 15) {
      score += 10;
    }

    // VWAP proximity (20 points) - price near VWAP is good for scalping
    final vwapDist = features.overExtVwap.abs();
    if (vwapDist < 0.01) {
      score += 20;
    } else if (vwapDist < 0.02) {
      score += 10;
    }

    // EMA position (20 points) - tidak terlalu jauh dari EMA
    final emaDist = features.overExtEma.abs();
    if (emaDist < 0.02) {
      score += 20;
    } else if (emaDist < 0.03) {
      score += 10;
    }

    // Structure (20 points)
    if (features.isRetest) score += 15;
    if (features.isBreakdown) score += 10;
    if (features.nearestSupport != null &&
        features.distToSupportATR != null &&
        features.distToSupportATR!.abs() < 3) {
      score += 10;
    }

    return score;
  }

  Map<String, dynamic> _getScalpingSignal(CoinData coin) {
    if (coin.features == null) return {};
    final features = coin.features!;
    String direction = '';
    String signal = '';
    Color color = Colors.grey;
    List<String> reasons = [];
    double? entry;
    double? stopLoss;
    double? takeProfit;

    // Analisis direction
    final priceChange = coin.priceChangePercent;
    final overEma = features.overExtEma;
    final overVwap = features.overExtVwap;

    // LONG setup
    if (priceChange < 0 &&
        overEma < 0 &&
        (features.isRetest || features.rsi < 45)) {
      direction = 'LONG';
      entry = coin.price;
      stopLoss = coin.price * 0.992; // 0.8% SL
      takeProfit = coin.price * 1.015; // 1.5% TP (1:1.87 RR)

      if (features.isRetest) reasons.add('Retest Support');
      if (overVwap < -0.01) reasons.add('Below VWAP');
      if (features.rsi < 45)
        reasons.add('RSI ${features.rsi.toStringAsFixed(0)}');

      if (reasons.length >= 2) {
        signal = '🟢 SCALP LONG';
        color = Colors.green;
      } else {
        signal = '🟡 WATCH LONG';
        color = Colors.yellow;
      }
    }
    // SHORT setup
    else if (priceChange > 0 &&
        overEma > 0 &&
        (features.isBreakdown || features.rsi > 55)) {
      direction = 'SHORT';
      entry = coin.price;
      stopLoss = coin.price * 1.008; // 0.8% SL
      takeProfit = coin.price * 0.985; // 1.5% TP (1:1.87 RR)

      if (features.isBreakdown) reasons.add('Breakdown');
      if (overVwap > 0.01) reasons.add('Above VWAP');
      if (features.rsi > 55)
        reasons.add('RSI ${features.rsi.toStringAsFixed(0)}');

      if (reasons.length >= 2) {
        signal = '🔴 SCALP SHORT';
        color = Colors.red;
      } else {
        signal = '🟠 WATCH SHORT';
        color = Colors.orange;
      }
    }
    // Ranging/Consolidation
    else {
      direction = 'RANGE';
      signal = '⚪ RANGING';
      color = Colors.grey;
      reasons.add('Wait breakout');
    }

    return {
      'signal': signal,
      'direction': direction,
      'color': color,
      'reasons': reasons,
      'entry': entry,
      'stopLoss': stopLoss,
      'takeProfit': takeProfit,
    };
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚡ Quick Scalping (15m)'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Target: 1-2% profit | SL: 0.8% | Timeframe: 15-30 menit',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Divider(height: 16),
              const Text(
                '📌 Cara Entry:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '• PRIORITAS: Score 60+ = Setup terbaik\n'
                '• Score 40-59 = Boleh entry tapi risk lebih tinggi\n'
                '• Score <40 = Skip, tunggu yang lebih baik',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade300),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Text(
                  '💡 Signal = Direction (Long/Short)\n'
                  'Score = Kualitas setup (momentum + posisi)\n'
                  'Entry terbaik: Signal ✓ + Score tinggi ✓',
                  style: TextStyle(fontSize: 10, color: Colors.amber.shade200),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Scalping Signals'),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.help_outline, size: 20),
              onPressed: _showInfoDialog,
              tooltip: 'Info',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<CoinData>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}'));
          }

          final coins = snapshot.data ?? [];
          final filteredCoins = _filterScalpingCoins(coins);
          
          if (filteredCoins.isEmpty) {
             return const Center(child: Text('No scalping signals found...'));
          }

          return ListView.builder(
              itemCount: filteredCoins.length,
              itemBuilder: (context, index) {
                final coin = filteredCoins[index];
                final features = coin.features!;
                final signalData = _getScalpingSignal(coin);
                final scalpingScore = _calculateScalpingScore(coin);
                
                // Safety check for map keys
                final color = (signalData['color'] as Color?) ?? Colors.grey;
                final direction = (signalData['direction'] as String?) ?? '';
                final signal = (signalData['signal'] as String?) ?? '';

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
                          builder: (context) => CoinDetailScreen(coin: coin),
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
                              // Direction Badge
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      direction == 'LONG'
                                          ? Icons.arrow_upward
                                          : direction == 'SHORT'
                                          ? Icons.arrow_downward
                                          : Icons.sync,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    Text(
                                      direction,
                                      style: const TextStyle(
                                        fontSize: 10,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    Row(
                                      children: [
                                        Text(
                                          '${coin.priceChangePercent.toStringAsFixed(2)}%',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: coin.priceChangePercent >= 0
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'RSI ${features.rsi.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Scalping Score with quality indicator
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Quality',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        scalpingScore.toStringAsFixed(0),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: scalpingScore >= 60
                                              ? Colors.green
                                              : scalpingScore >= 40
                                              ? Colors.orange
                                              : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      if (scalpingScore >= 60)
                                        const Icon(
                                          Icons.star,
                                          color: Colors.green,
                                          size: 16,
                                        )
                                      else if (scalpingScore >= 40)
                                        const Icon(
                                          Icons.star_half,
                                          color: Colors.orange,
                                          size: 16,
                                        )
                                      else
                                        const Icon(
                                          Icons.star_border,
                                          color: Colors.grey,
                                          size: 16,
                                        ),
                                    ],
                                  ),
                                  Text(
                                    scalpingScore >= 60
                                        ? 'Best'
                                        : scalpingScore >= 40
                                        ? 'OK'
                                        : 'Skip',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: scalpingScore >= 60
                                          ? Colors.green
                                          : scalpingScore >= 40
                                          ? Colors.orange
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Signal
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: color.withOpacity(0.5),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        signal,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                        ),
                                      ),
                                    ),
                                    // Recommendation based on score
                                    if (scalpingScore >= 60)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Text(
                                          'ENTRY NOW',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    else if (scalpingScore >= 40)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Text(
                                          'RISKY',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Text(
                                          'SKIP',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if ((signalData['reasons'] as List?)?.isNotEmpty ?? false) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    (signalData['reasons'] as List).join(' • '),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Entry/SL/TP info
                          if (signalData['entry'] != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildPriceInfo(
                                    'Entry',
                                    signalData['entry'],
                                    Colors.blue,
                                  ),
                                  _buildPriceInfo(
                                    'SL',
                                    signalData['stopLoss'],
                                    Colors.red,
                                  ),
                                  _buildPriceInfo(
                                    'TP',
                                    signalData['takeProfit'],
                                    Colors.green,
                                  ),
                                ],
                              ),
                            ),
                          ],

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
                              _buildBadge(
                                'EMA ${(features.overExtEma * 100).toStringAsFixed(1)}%',
                                features.overExtEma > 0
                                    ? Colors.red.shade700
                                    : Colors.green.shade700,
                              ),
                              _buildBadge(
                                'VWAP ${(features.overExtVwap * 100).toStringAsFixed(1)}%',
                                features.overExtVwap > 0
                                    ? Colors.orange.shade700
                                    : Colors.blue.shade700,
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
        }
      ),
    );
  }

  Widget _buildPriceInfo(String label, double? value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value != null
              ? '\$${value > 1 ? value.toStringAsFixed(2) : value.toStringAsFixed(5)}'
              : '-',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade300,
          ),
        ),
      ],
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

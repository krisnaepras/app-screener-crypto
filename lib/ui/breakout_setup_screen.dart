import 'package:flutter/material.dart';
import '../models/coin_data.dart';
import 'breakout_detail_screen.dart';

class BreakoutSetupScreen extends StatelessWidget {
  final List<CoinData> coins;
  final VoidCallback onRefresh;

  const BreakoutSetupScreen({
    super.key,
    required this.coins,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Filter coins by breakout status
    final breakoutCoins =
        coins
            .where(
              (coin) =>
                  coin.breakoutStatus.isNotEmpty && coin.breakoutScore >= 30,
            )
            .toList()
          ..sort((a, b) => b.breakoutScore.compareTo(a.breakoutScore));

    // Group by direction and status
    // LONG breakouts
    final confirmedBreakoutsLong = breakoutCoins
        .where((coin) => coin.breakoutStatus == 'BREAKOUT_LONG')
        .toList();
    final testingCoinsLong = breakoutCoins
        .where((coin) => coin.breakoutStatus == 'TESTING_LONG')
        .toList();
    final watchingCoinsLong = breakoutCoins
        .where((coin) => coin.breakoutStatus == 'WAIT_LONG')
        .toList();

    // SHORT breakdowns
    final confirmedBreakoutsShort = breakoutCoins
        .where((coin) => coin.breakoutStatus == 'BREAKOUT_SHORT')
        .toList();
    final testingCoinsShort = breakoutCoins
        .where((coin) => coin.breakoutStatus == 'TESTING_SHORT')
        .toList();
    final watchingCoinsShort = breakoutCoins
        .where((coin) => coin.breakoutStatus == 'WAIT_SHORT')
        .toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          onRefresh();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: breakoutCoins.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_flat,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada setup breakout',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Menunggu koin breakout resistance',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.rocket_launch,
                                color: Colors.blue.shade700,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Breakout Hunter',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Deteksi koin yang breakout dari resistance dengan konfirmasi volume spike',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.timeline,
                                size: 16,
                                color: Colors.blue.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Timeframes: 15m + 1h',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Statistics
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'LONG',
                          confirmedBreakoutsLong.length +
                              testingCoinsLong.length +
                              watchingCoinsLong.length,
                          Colors.green,
                          Icons.trending_up,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'SHORT',
                          confirmedBreakoutsShort.length +
                              testingCoinsShort.length +
                              watchingCoinsShort.length,
                          Colors.red,
                          Icons.trending_down,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'TOTAL',
                          breakoutCoins.length,
                          Colors.blue,
                          Icons.show_chart,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // LONG BREAKOUTS Section
                  if (confirmedBreakoutsLong.isNotEmpty) ...[
                    _buildSectionHeader(
                      '🚀 BREAKOUT LONG - Buy!',
                      'Resistance breakout confirmed dengan volume spike',
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                    ...confirmedBreakoutsLong.map(
                      (coin) => _buildBreakoutCard(context, coin),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (testingCoinsLong.isNotEmpty) ...[
                    _buildSectionHeader(
                      '🔸 TESTING LONG - Watch',
                      'Testing resistance level',
                      Colors.green.shade300,
                    ),
                    const SizedBox(height: 8),
                    ...testingCoinsLong.map(
                      (coin) => _buildBreakoutCard(context, coin),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (watchingCoinsLong.isNotEmpty) ...[
                    _buildSectionHeader(
                      '⏳ WAIT LONG - Monitor',
                      'Perhatikan untuk potensi breakout',
                      Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    ...watchingCoinsLong.map(
                      (coin) => _buildBreakoutCard(context, coin),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // SHORT BREAKDOWNS Section
                  if (confirmedBreakoutsShort.isNotEmpty) ...[
                    _buildSectionHeader(
                      '📉 BREAKOUT SHORT - Sell!',
                      'Support breakdown confirmed dengan volume spike',
                      Colors.red,
                    ),
                    const SizedBox(height: 8),
                    ...confirmedBreakoutsShort.map(
                      (coin) => _buildBreakoutCard(context, coin),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (testingCoinsShort.isNotEmpty) ...[
                    _buildSectionHeader(
                      '🔻 TESTING SHORT - Watch',
                      'Testing support level',
                      Colors.red.shade300,
                    ),
                    const SizedBox(height: 8),
                    ...testingCoinsShort.map(
                      (coin) => _buildBreakoutCard(context, coin),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (watchingCoinsShort.isNotEmpty) ...[
                    _buildSectionHeader(
                      '⏳ WAIT SHORT - Monitor',
                      'Perhatikan untuk potensi breakdown',
                      Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    ...watchingCoinsShort.map(
                      (coin) => _buildBreakoutCard(context, coin),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildBreakoutCard(BuildContext context, CoinData coin) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    // Parse direction from status
    final isLong = coin.breakoutDirection == 'LONG';
    final baseStatus = coin.breakoutStatus
        .replaceAll('_LONG', '')
        .replaceAll('_SHORT', '');

    switch (baseStatus) {
      case 'BREAKOUT':
        statusColor = isLong ? Colors.green : Colors.red;
        statusIcon = isLong ? Icons.rocket_launch : Icons.trending_down;
        statusText = isLong ? 'BREAKOUT' : 'BREAKDOWN';
        break;
      case 'TESTING':
        statusColor = isLong ? Colors.green.shade300 : Colors.red.shade300;
        statusIcon = isLong ? Icons.trending_up : Icons.trending_down;
        statusText = 'TESTING';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.watch_later;
        statusText = 'WATCHING';
    }

    // Get TF scores
    final tf15m = coin.breakoutTfScores.firstWhere(
      (s) => s.tf == '15m',
      orElse: () => TimeframeScore(tf: '15m', score: 0),
    );
    final tf1h = coin.breakoutTfScores.firstWhere(
      (s) => s.tf == '1h',
      orElse: () => TimeframeScore(tf: '1h', score: 0),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BreakoutDetailScreen(coin: coin),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Symbol
                  Expanded(
                    child: Text(
                      coin.symbol,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Price & Change
              Row(
                children: [
                  Text(
                    '\$${coin.price.toStringAsFixed(4)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: coin.priceChangePercent >= 0
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${coin.priceChangePercent >= 0 ? '+' : ''}${coin.priceChangePercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: coin.priceChangePercent >= 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Score & TF Scores
              Row(
                children: [
                  // Total Score
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Score',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            coin.breakoutScore.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 15m Score
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '15m',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            tf15m.score.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 1h Score
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '1h',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            tf1h.score.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Features
              if (coin.breakoutFeatures != null) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (coin.breakoutFeatures!.rsi > 50)
                      _buildFeatureBadge(
                        '📈 RSI ${coin.breakoutFeatures!.rsi.toStringAsFixed(0)}',
                        Colors.blue,
                      ),
                    if (coin.breakoutFeatures!.volumeDeclineRatio < -0.3)
                      _buildFeatureBadge('📊 Volume Spike', Colors.purple),
                    if (coin.breakoutFeatures!.overExtEma > 0.01)
                      _buildFeatureBadge('🎯 Above EMA', Colors.green),
                    if (!coin.breakoutFeatures!.isAboveUpperBand)
                      _buildFeatureBadge('✅ Room to Run', Colors.teal),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

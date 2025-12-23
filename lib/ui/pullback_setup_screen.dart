import 'package:flutter/material.dart';
import '../models/coin_data.dart';
import '../scoring/features.dart';
import 'pullback_detail_screen.dart';

class PullbackSetupScreen extends StatelessWidget {
  final List<CoinData> coins;
  final VoidCallback? onRefresh;

  const PullbackSetupScreen({super.key, required this.coins, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    // Filter coins with pullback status
    final dipCoins = coins.where((c) => c.pullbackStatus == 'DIP').toList();
    final bounceCoins = coins
        .where((c) => c.pullbackStatus == 'BOUNCE')
        .toList();
    final waitCoins = coins.where((c) => c.pullbackStatus == 'WAIT').toList();

    // Sort by pullback score
    dipCoins.sort((a, b) => b.pullbackScore.compareTo(a.pullbackScore));
    bounceCoins.sort((a, b) => b.pullbackScore.compareTo(a.pullbackScore));
    waitCoins.sort((a, b) => b.pullbackScore.compareTo(a.pullbackScore));

    return Scaffold(
      backgroundColor: const Color(0xFF0D1421),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2332),
        title: const Text(
          '📈 Pullback Entry (Buy the Dip)',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: onRefresh,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => onRefresh?.call(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.3),
                    Colors.teal.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🟢 BUY THE DIP - Cari entry BUY saat uptrend koreksi. Setup di 5m/15m, eksekusi di 1m/3m.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // DIP Section - Ready to buy
            _buildStatusSection(
              context,
              title: '🎯 DIP - Ready to Buy!',
              subtitle: 'Uptrend + Pullback + Bounce confirmed',
              coins: dipCoins,
              statusColor: Colors.green,
              gradientColors: [
                Colors.green.withOpacity(0.2),
                Colors.teal.withOpacity(0.1),
              ],
            ),

            // BOUNCE Section - Starting to bounce
            _buildStatusSection(
              context,
              title: '📈 BOUNCE - Confirming',
              subtitle: 'Uptrend + Pullback, waiting bounce',
              coins: bounceCoins,
              statusColor: Colors.teal,
              gradientColors: [
                Colors.teal.withOpacity(0.2),
                Colors.cyan.withOpacity(0.1),
              ],
            ),

            // WAIT Section - Watching
            _buildStatusSection(
              context,
              title: '⏳ WAIT - Watching',
              subtitle: 'Setup forming, not ready yet',
              coins: waitCoins,
              statusColor: Colors.blue,
              gradientColors: [
                Colors.blue.withOpacity(0.2),
                Colors.indigo.withOpacity(0.1),
              ],
            ),

            if (dipCoins.isEmpty && bounceCoins.isEmpty && waitCoins.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.hourglass_empty,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada setup pullback yang terdeteksi',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<CoinData> coins,
    required Color statusColor,
    required List<Color> gradientColors,
  }) {
    if (coins.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${coins.length}',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        const SizedBox(height: 8),
        ...coins.map((coin) => _buildCoinCard(context, coin, statusColor)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCoinCard(
    BuildContext context,
    CoinData coin,
    Color statusColor,
  ) {
    // Get TF scores
    final tf5m = coin.pullbackTfScores.where((t) => t.tf == '5m').firstOrNull;
    final tf15m = coin.pullbackTfScores.where((t) => t.tf == '15m').firstOrNull;
    final tf1m = coin.pullbackTfScores.where((t) => t.tf == '1m').firstOrNull;
    final tf3m = coin.pullbackTfScores.where((t) => t.tf == '3m').firstOrNull;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PullbackDetailScreen(coin: coin),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Symbol
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    coin.symbol.replaceAll('USDT', ''),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Colors.green,
                        size: 10,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        coin.pullbackStatus,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${_formatPrice(coin.price)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${coin.priceChangePercent >= 0 ? '+' : ''}${coin.priceChangePercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: coin.priceChangePercent >= 0
                            ? Colors.green
                            : Colors.red,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // TF Scores Row - Setup (5m, 15m) + Execution (1m, 3m)
            Row(
              children: [
                // Pullback Score
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Score',
                          style: TextStyle(color: Colors.green, fontSize: 10),
                        ),
                        Text(
                          coin.pullbackScore.toStringAsFixed(0),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // 5m TF (Setup)
                Expanded(child: _buildTfBox('5m', tf5m, 'Setup')),
                const SizedBox(width: 6),
                // 15m TF (Setup)
                Expanded(child: _buildTfBox('15m', tf15m, 'Setup')),
                const SizedBox(width: 6),
                // 1m TF (Exec)
                Expanded(child: _buildTfBox('1m', tf1m, 'Exec')),
              ],
            ),
            const SizedBox(height: 8),
            // Feature indicators
            if (coin.pullbackFeatures != null) ...[
              Row(
                children: [
                  if (coin.pullbackFeatures!.rsi < 45 &&
                      coin.pullbackFeatures!.rsi > 25)
                    _buildFeatureBadge('� RSI Pullback', Colors.orange),
                  if (coin.pullbackFeatures!.distToSupportATR != null &&
                      coin.pullbackFeatures!.distToSupportATR! < 2)
                    _buildFeatureBadge('🎯 Near Support', Colors.green),
                  if (coin.priceChangePercent > 0)
                    _buildFeatureBadge('📈 Uptrend', Colors.teal),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTfBox(String label, TimeframeScore? tfScore, String type) {
    final color = type == 'Setup' ? Colors.blue : Colors.purple;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: _getTfColor(tfScore?.score ?? 0).withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${tfScore?.score.toStringAsFixed(0) ?? '-'}',
            style: TextStyle(
              color: _getTfColor(tfScore?.score ?? 0),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          if (tfScore != null)
            Text(
              'RSI ${tfScore.rsi.toStringAsFixed(0)}',
              style: TextStyle(
                color: _getRsiColorForBuy(tfScore.rsi),
                fontSize: 8,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getTfColor(double score) {
    if (score >= 45) return Colors.green;
    if (score >= 35) return Colors.teal;
    if (score >= 25) return Colors.orange;
    return Colors.grey;
  }

  Color _getRsiColorForBuy(double rsi) {
    // For buying dips, low RSI is good
    if (rsi <= 35) return Colors.green; // Oversold - good for buy
    if (rsi <= 45) return Colors.teal; // Pullback zone
    if (rsi >= 65) return Colors.red; // Overbought - risky buy
    return Colors.grey;
  }

  String _formatPrice(double price) {
    if (price >= 1000) return price.toStringAsFixed(2);
    if (price >= 1) return price.toStringAsFixed(4);
    return price.toStringAsFixed(6);
  }
}

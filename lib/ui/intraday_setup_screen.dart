import 'package:flutter/material.dart';
import '../models/coin_data.dart';
import '../scoring/features.dart';
import 'intraday_detail_screen.dart';

class IntradaySetupScreen extends StatelessWidget {
  final List<CoinData> coins;
  final VoidCallback? onRefresh;

  const IntradaySetupScreen({super.key, required this.coins, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    // Filter coins with intraday status
    final hotCoins = coins.where((c) => c.intradayStatus == 'HOT').toList();
    final warmCoins = coins.where((c) => c.intradayStatus == 'WARM').toList();
    final coolCoins = coins.where((c) => c.intradayStatus == 'COOL').toList();

    // Sort by intraday score
    hotCoins.sort((a, b) => b.intradayScore.compareTo(a.intradayScore));
    warmCoins.sort((a, b) => b.intradayScore.compareTo(a.intradayScore));
    coolCoins.sort((a, b) => b.intradayScore.compareTo(a.intradayScore));

    return Scaffold(
      backgroundColor: const Color(0xFF0D1421),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2332),
        title: const Text(
          '� Intraday SHORT (15m + 1h)',
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
                    Colors.red.withOpacity(0.3),
                    Colors.orange.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.trending_down, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🔻 SHORT ONLY - Mencari setup SELL berdasarkan overbought di TF 15m + 1h. Target 1-4 jam.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // HOT Section
            _buildStatusSection(
              context,
              title: '🔥 HOT SHORT - Ready to Sell',
              subtitle: '2 TF Overbought, Score ≥45',
              coins: hotCoins,
              statusColor: Colors.red,
              gradientColors: [
                Colors.red.withOpacity(0.2),
                Colors.orange.withOpacity(0.1),
              ],
            ),

            // WARM Section
            _buildStatusSection(
              context,
              title: '🌡️ WARM SHORT - Almost Ready',
              subtitle: '1 TF Overbought, Score ≥35',
              coins: warmCoins,
              statusColor: Colors.orange,
              gradientColors: [
                Colors.orange.withOpacity(0.2),
                Colors.yellow.withOpacity(0.1),
              ],
            ),

            // COOL Section
            _buildStatusSection(
              context,
              title: '❄️ COOL SHORT - Watchlist',
              subtitle: 'Score ≥30, Building Short Setup',
              coins: coolCoins,
              statusColor: Colors.blue,
              gradientColors: [
                Colors.blue.withOpacity(0.2),
                Colors.cyan.withOpacity(0.1),
              ],
            ),

            if (hotCoins.isEmpty && warmCoins.isEmpty && coolCoins.isEmpty)
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
                        'Belum ada setup SHORT intraday yang terdeteksi',
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
    // Get 15m and 1h TF scores
    final tf15m = coin.intradayTfScores.where((t) => t.tf == '15m').firstOrNull;
    final tf1h = coin.intradayTfScores.where((t) => t.tf == '1h').firstOrNull;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IntradayDetailScreen(coin: coin),
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
                  child: Text(
                    coin.intradayStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
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
            // TF Scores Row
            Row(
              children: [
                // Intraday Score
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Score',
                          style: TextStyle(color: Colors.purple, fontSize: 10),
                        ),
                        Text(
                          coin.intradayScore.toStringAsFixed(0),
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
                const SizedBox(width: 8),
                // 15m TF
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: _getTfColor(tf15m?.score ?? 0).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '15m',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                        Text(
                          '${tf15m?.score.toStringAsFixed(0) ?? '-'}',
                          style: TextStyle(
                            color: _getTfColor(tf15m?.score ?? 0),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (tf15m != null)
                          Text(
                            'RSI ${tf15m.rsi.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: _getRsiColor(tf15m.rsi),
                              fontSize: 9,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 1h TF
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: _getTfColor(tf1h?.score ?? 0).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '1h',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                        Text(
                          '${tf1h?.score.toStringAsFixed(0) ?? '-'}',
                          style: TextStyle(
                            color: _getTfColor(tf1h?.score ?? 0),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (tf1h != null)
                          Text(
                            'RSI ${tf1h.rsi.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: _getRsiColor(tf1h.rsi),
                              fontSize: 9,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Feature indicators if available
            if (coin.intradayFeatures != null) ...[
              Row(
                children: [
                  if (coin.intradayFeatures!.hasVolumeSurge)
                    _buildFeatureBadge('📈 Vol Surge', Colors.green),
                  if (coin.intradayFeatures!.hasBbSqueeze)
                    _buildFeatureBadge('🎯 BB Squeeze', Colors.orange),
                  if (coin.intradayFeatures!.hasRsiDivergence)
                    _buildFeatureBadge('📊 RSI Div', Colors.purple),
                  if (coin.intradayFeatures!.isMaAligned)
                    _buildFeatureBadge('📐 MA Aligned', Colors.blue),
                ],
              ),
            ],
          ],
        ),
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
    if (score >= 40) return Colors.green;
    if (score >= 30) return Colors.orange;
    return Colors.grey;
  }

  Color _getRsiColor(double rsi) {
    if (rsi <= 30) return Colors.green;
    if (rsi >= 70) return Colors.red;
    return Colors.grey;
  }

  String _formatPrice(double price) {
    if (price >= 1000) return price.toStringAsFixed(2);
    if (price >= 1) return price.toStringAsFixed(4);
    return price.toStringAsFixed(6);
  }
}

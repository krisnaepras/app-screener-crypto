import 'package:flutter/material.dart';
import '../models/coin_data.dart';
import '../scoring/features.dart';

class PullbackDetailScreen extends StatelessWidget {
  final CoinData coin;

  const PullbackDetailScreen({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    final features = coin.pullbackFeatures;
    Color statusColor = _getStatusColor(coin.pullbackStatus);

    // Separate setup and execution TFs
    final setupTFs = coin.pullbackTfScores
        .where((t) => t.tf == '5m' || t.tf == '15m')
        .toList();
    final execTFs = coin.pullbackTfScores
        .where((t) => t.tf == '1m' || t.tf == '3m')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1421),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2332),
        title: Row(
          children: [
            Text(
              coin.symbol.replaceAll('USDT', ''),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.trending_up, color: Colors.green, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'BUY ${coin.pullbackStatus}',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          _buildHeaderCard(statusColor),
          const SizedBox(height: 16),

          // Setup TF Analysis (5m, 15m)
          _buildTfSectionCard(
            '📊 Setup Timeframes',
            'Trend & Pullback Analysis',
            setupTFs,
            Colors.blue,
          ),
          const SizedBox(height: 12),

          // Execution TF Analysis (1m, 3m)
          _buildTfSectionCard(
            '🎯 Execution Timeframes',
            'Entry Timing',
            execTFs,
            Colors.purple,
          ),
          const SizedBox(height: 16),

          // Market Features Card
          if (features != null) ...[
            _buildMarketFeaturesCard(features),
            const SizedBox(height: 16),
          ],

          // Trading Guide Card
          _buildTradingGuideCard(),
          const SizedBox(height: 16),

          // Risk Management Card
          _buildRiskManagementCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.3), const Color(0xFF1A2332)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Price',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    '\$${_formatPrice(coin.price)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${coin.priceChangePercent >= 0 ? '+' : ''}${coin.priceChangePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: coin.priceChangePercent >= 0
                          ? Colors.green
                          : Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Pullback Score',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getScoreColor(
                        coin.pullbackScore,
                      ).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      coin.pullbackScore.toStringAsFixed(0),
                      style: TextStyle(
                        color: _getScoreColor(coin.pullbackScore),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Status Explanation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(coin.pullbackStatus),
                  color: statusColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coin.pullbackStatus,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _getStatusDescription(coin.pullbackStatus),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTfSectionCard(
    String title,
    String subtitle,
    List<TimeframeScore> tfScores,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (tfScores.isEmpty)
            const Center(
              child: Text(
                'No data available',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            Row(
              children: tfScores.map((tf) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getScoreColor(tf.score).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getScoreColor(tf.score).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          tf.tf.toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tf.score.toStringAsFixed(0),
                          style: TextStyle(
                            color: _getScoreColor(tf.score),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getRsiColorForBuy(tf.rsi).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'RSI ${tf.rsi.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: _getRsiColorForBuy(tf.rsi),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getRsiLabel(tf.rsi),
                          style: TextStyle(
                            color: _getRsiColorForBuy(tf.rsi).withOpacity(0.8),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildMarketFeaturesCard(MarketFeatures features) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: Colors.cyan, size: 20),
              SizedBox(width: 8),
              Text(
                'Market Conditions',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeatureChip(
                'RSI Pullback',
                features.rsi < 45 && features.rsi > 25,
                Icons.show_chart,
                Colors.green,
              ),
              _buildFeatureChip(
                'Near Support',
                features.distToSupportATR != null &&
                    features.distToSupportATR! < 2,
                Icons.support,
                Colors.teal,
              ),
              _buildFeatureChip(
                'Not Breakdown',
                !features.isBreakdown,
                Icons.check_circle,
                Colors.blue,
              ),
              _buildFeatureChip(
                'Low Rejection',
                features.rejectionWickRatio < 0.3,
                Icons.thumb_up,
                Colors.purple,
              ),
              _buildFeatureChip(
                'Losing Momentum',
                features.isLosingMomentum,
                Icons.warning,
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Key metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricBox(
                  'RSI',
                  features.rsi.toStringAsFixed(1),
                  _getRsiColorForBuy(features.rsi),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricBox(
                  'EMA Dist',
                  '${(features.overExtEma * 100).toStringAsFixed(1)}%',
                  features.overExtEma > -0.02 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricBox(
                  'Funding',
                  '${(features.fundingRate * 100).toStringAsFixed(3)}%',
                  features.fundingRate < 0.0005 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(
    String label,
    bool isActive,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive
              ? color.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? color : Colors.grey, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? color : Colors.grey,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            color: isActive ? color : Colors.grey,
            size: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildTradingGuideCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Pullback Entry Guide',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuideItem(
            '1',
            'Konfirmasi uptrend di TF 15m (EMA20 > EMA50)',
            Colors.blue,
          ),
          _buildGuideItem(
            '2',
            'Tunggu pullback ke area EMA atau support',
            Colors.teal,
          ),
          _buildGuideItem(
            '3',
            'Entry BUY di TF 1m/3m saat RSI bounce dari oversold',
            Colors.green,
          ),
          _buildGuideItem(
            '4',
            'Target: Higher high berikutnya, RR minimal 1:2',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(String number, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskManagementCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.withOpacity(0.2), Colors.teal.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Risk Management (BUY)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• Stop Loss: Di bawah swing low terakhir (0.5-1%)\n'
            '• Risk per trade: Max 2% dari modal\n'
            '• Risk:Reward minimal 1:2\n'
            '• Cut loss jika breakdown support dengan volume\n'
            '• Jangan beli saat downtrend kuat (lower lows)',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'DIP':
        return Colors.green;
      case 'BOUNCE':
        return Colors.teal;
      case 'WAIT':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'DIP':
        return Icons.arrow_downward;
      case 'BOUNCE':
        return Icons.trending_up;
      case 'WAIT':
        return Icons.hourglass_empty;
      default:
        return Icons.help;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'DIP':
        return 'Uptrend + Pullback + Bounce confirmed - Ready to buy!';
      case 'BOUNCE':
        return 'Uptrend + Pullback detected, waiting for bounce';
      case 'WAIT':
        return 'Setup forming, not ready yet';
      default:
        return 'No clear setup detected';
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 45) return Colors.green;
    if (score >= 35) return Colors.teal;
    if (score >= 25) return Colors.orange;
    return Colors.grey;
  }

  Color _getRsiColorForBuy(double rsi) {
    if (rsi <= 35) return Colors.green; // Oversold - good for buy
    if (rsi <= 45) return Colors.teal; // Pullback zone
    if (rsi >= 65) return Colors.red; // Overbought - risky buy
    return Colors.grey;
  }

  String _getRsiLabel(double rsi) {
    if (rsi <= 30) return 'Oversold';
    if (rsi <= 40) return 'Pullback';
    if (rsi <= 50) return 'Neutral';
    if (rsi >= 70) return 'Overbought';
    return 'Normal';
  }

  String _formatPrice(double price) {
    if (price >= 1000) return price.toStringAsFixed(2);
    if (price >= 1) return price.toStringAsFixed(4);
    return price.toStringAsFixed(6);
  }
}

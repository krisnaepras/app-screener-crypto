import 'package:flutter/material.dart';
import '../models/coin_data.dart';
import '../scoring/features.dart';

class IntradayDetailScreen extends StatelessWidget {
  final CoinData coin;

  const IntradayDetailScreen({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    final tf15m = coin.intradayTfScores.where((t) => t.tf == '15m').firstOrNull;
    final tf1h = coin.intradayTfScores.where((t) => t.tf == '1h').firstOrNull;
    final features = coin.intradayFeatures;

    Color statusColor = _getStatusColor(coin.intradayStatus);

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
                  const Icon(Icons.trending_down, color: Colors.red, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'SHORT ${coin.intradayStatus}',
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

          // TF Analysis Cards
          _buildTfAnalysisCard('15 Minutes (15m)', tf15m, Colors.blue),
          const SizedBox(height: 12),
          _buildTfAnalysisCard('1 Hour (1h)', tf1h, Colors.purple),
          const SizedBox(height: 16),

          // Market Features Card
          if (features != null) ...[
            _buildMarketFeaturesCard(features),
            const SizedBox(height: 16),
          ],

          // Momentum Analysis
          if (features != null) ...[
            _buildMomentumCard(features),
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
                    'Intraday Score',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getScoreColor(
                        coin.intradayScore,
                      ).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      coin.intradayScore.toStringAsFixed(0),
                      style: TextStyle(
                        color: _getScoreColor(coin.intradayScore),
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
                  _getStatusIcon(coin.intradayStatus),
                  color: statusColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coin.intradayStatus,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _getStatusDescription(coin.intradayStatus),
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

  Widget _buildTfAnalysisCard(
    String title,
    TimeframeScore? tfScore,
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
              if (tfScore != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(tfScore.score).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Score: ${tfScore.score.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: _getScoreColor(tfScore.score),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (tfScore != null) ...[
            Row(
              children: [
                Expanded(
                  child: _buildMetricBox(
                    'RSI',
                    tfScore.rsi.toStringAsFixed(1),
                    _getRsiColor(tfScore.rsi),
                    _getRsiLabel(tfScore.rsi),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricBox(
                    'Signal',
                    tfScore.score >= 40
                        ? 'BULLISH'
                        : tfScore.score >= 30
                        ? 'NEUTRAL'
                        : 'WAIT',
                    tfScore.score >= 40
                        ? Colors.green
                        : tfScore.score >= 30
                        ? Colors.orange
                        : Colors.grey,
                    tfScore.score >= 40 ? 'Entry Ready' : 'Building',
                  ),
                ),
              ],
            ),
          ] else
            const Center(
              child: Text(
                'No data available',
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricBox(
    String label,
    String value,
    Color color,
    String subLabel,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            subLabel,
            style: TextStyle(color: color.withOpacity(0.7), fontSize: 10),
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
                'Market Features',
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
                'Volume Surge',
                features.hasVolumeSurge,
                Icons.show_chart,
                Colors.green,
              ),
              _buildFeatureChip(
                'BB Squeeze',
                features.hasBbSqueeze,
                Icons.compress,
                Colors.orange,
              ),
              _buildFeatureChip(
                'RSI Divergence',
                features.hasRsiDivergence,
                Icons.trending_up,
                Colors.purple,
              ),
              _buildFeatureChip(
                'MA Aligned',
                features.isMaAligned,
                Icons.stacked_line_chart,
                Colors.blue,
              ),
              _buildFeatureChip(
                'Momentum Loss',
                features.isLosingMomentum,
                Icons.warning,
                Colors.red,
              ),
            ],
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

  Widget _buildMomentumCard(MarketFeatures features) {
    final isLosingMomentum = features.isLosingMomentum;
    final color = isLosingMomentum ? Colors.red : Colors.green;

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
              Icon(
                isLosingMomentum ? Icons.trending_down : Icons.trending_up,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Momentum Analysis',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isLosingMomentum ? 'LOSING' : 'STRONG',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMomentumMetric(
                  'Momentum Slope',
                  features.momentumSlope.toStringAsFixed(2),
                  features.momentumSlope >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMomentumMetric(
                  'RSI Slope',
                  features.rsiSlope.toStringAsFixed(2),
                  features.rsiSlope >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMomentumMetric(
                  'Vol Decline',
                  '${(features.volumeDeclineRatio * 100).toStringAsFixed(0)}%',
                  features.volumeDeclineRatio < 0.8 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          if (isLosingMomentum) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Momentum melemah! Pertimbangkan untuk menunggu konfirmasi sebelum entry.',
                      style: TextStyle(color: Colors.red, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMomentumMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9)),
          const SizedBox(height: 2),
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
              Icon(Icons.trending_down, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text(
                'SHORT Trading Guide',
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
            'Konfirmasi RSI overbought (>65) di TF 1h',
            Colors.red,
          ),
          _buildGuideItem(
            '2',
            'Tunggu rejection candle atau bearish divergence',
            Colors.orange,
          ),
          _buildGuideItem(
            '3',
            'Entry SHORT saat harga break support di TF 15m',
            Colors.purple,
          ),
          _buildGuideItem(
            '4',
            'Stop loss di atas recent high, target 1-2%',
            Colors.blue,
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
          colors: [Colors.red.withOpacity(0.2), Colors.orange.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text(
                'SHORT Risk Management',
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
            '• Stop Loss: Di atas recent high (0.5-1%)\n'
            '• Risk per trade: Max 2% dari modal\n'
            '• Risk:Reward minimal 1:2\n'
            '• Cut loss jika harga break up dengan volume\n'
            '• Jangan counter-trend di strong uptrend',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'HOT':
        return Colors.red;
      case 'WARM':
        return Colors.orange;
      case 'COOL':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'HOT':
        return Icons.local_fire_department;
      case 'WARM':
        return Icons.thermostat;
      case 'COOL':
        return Icons.ac_unit;
      default:
        return Icons.help;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'HOT':
        return '2 TF Aligned, Score ≥45 - Ready for entry!';
      case 'WARM':
        return '1 TF Aligned, Score ≥35 - Almost ready';
      case 'COOL':
        return 'Score ≥30 - Building setup, monitor closely';
      default:
        return 'No clear setup detected';
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 45) return Colors.green;
    if (score >= 35) return Colors.orange;
    return Colors.grey;
  }

  Color _getRsiColor(double rsi) {
    if (rsi <= 30) return Colors.green;
    if (rsi >= 70) return Colors.red;
    return Colors.grey;
  }

  String _getRsiLabel(double rsi) {
    if (rsi <= 30) return 'Oversold';
    if (rsi >= 70) return 'Overbought';
    return 'Neutral';
  }

  String _formatPrice(double price) {
    if (price >= 1000) return price.toStringAsFixed(2);
    if (price >= 1) return price.toStringAsFixed(4);
    return price.toStringAsFixed(6);
  }
}

import 'package:flutter/material.dart';
import '../models/coin_data.dart';
import '../scoring/features.dart';

class FollowTrendDetailScreen extends StatelessWidget {
  final CoinData coin;

  const FollowTrendDetailScreen({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    final features = coin.followTrendFeatures;
    final isLong = coin.followTrendDirection == 'LONG';
    final directionColor = isLong ? Colors.green : Colors.red;

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
                color: directionColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isLong ? Icons.trending_up : Icons.trending_down,
                    color: directionColor,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    coin.followTrendDirection,
                    style: TextStyle(
                      color: directionColor,
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
          _buildHeaderCard(directionColor),
          const SizedBox(height: 16),

          // Strategy Info Card
          _buildStrategyCard(isLong),
          const SizedBox(height: 16),

          // Market Features Card
          if (features != null) ...[
            _buildFeaturesCard(features),
            const SizedBox(height: 16),
          ],

          // Entry Guide Card
          _buildEntryGuideCard(isLong),
          const SizedBox(height: 16),

          // Risk Management Card
          _buildRiskCard(isLong),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), const Color(0xFF1A2332)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
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
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${coin.price.toStringAsFixed(coin.price > 100 ? 2 : 4)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'SCORE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      coin.followTrendScore.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric(
                'Change 24h',
                '${coin.priceChangePercent.toStringAsFixed(2)}%',
                coin.priceChangePercent >= 0 ? Colors.green : Colors.red,
              ),
              _buildMetric(
                'Funding',
                '${(coin.fundingRate * 100).toStringAsFixed(3)}%',
                coin.fundingRate >= 0 ? Colors.green : Colors.red,
              ),
              if (coin.followTrendStatus.isNotEmpty)
                _buildMetric(
                  'Status',
                  coin.followTrendStatus,
                  _getStatusColor(coin.followTrendStatus),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStrategyCard(bool isLong) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isLong ? Icons.trending_up : Icons.trending_down,
                color: isLong ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Follow Trend Strategy',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isLong
                ? '📈 LONG Position: Trend sedang bullish kuat. Ikuti momentum naik dengan entry bertahap dan trailing stop loss.'
                : '📉 SHORT Position: Trend sedang bearish kuat. Ikuti momentum turun dengan entry bertahap dan trailing stop loss.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLong
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLong ? '🎯 Target LONG:' : '🎯 Target SHORT:',
                  style: TextStyle(
                    color: isLong ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLong
                      ? '• Ride the trend hingga reversal signal\n• Scale out di resistance levels\n• Protect profit dengan trailing stop'
                      : '• Ride the trend hingga reversal signal\n• Scale out di support levels\n• Protect profit dengan trailing stop',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard(MarketFeatures features) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(16),
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
              _buildFeatureChip('Volume', features.hasVolumeSurge, Icons.show_chart),
              _buildFeatureChip('MA Aligned', features.isMaAligned, Icons.align_horizontal_left),
              _buildFeatureChip('BB Squeeze', features.hasBbSqueeze, Icons.compress),
              _buildFeatureChip('No Divergence', !features.hasVolumeDivergence && !features.hasRsiDivergence, Icons.trending_up),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, bool active, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? Colors.green.withOpacity(0.2)
            : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? Colors.green : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: active ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: active ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryGuideCard(bool isLong) {
    final entryPrice = coin.price;
    final sl = isLong ? entryPrice * 0.97 : entryPrice * 1.03;
    final tp1 = isLong ? entryPrice * 1.05 : entryPrice * 0.95;
    final tp2 = isLong ? entryPrice * 1.10 : entryPrice * 0.90;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calculate, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Entry Guide',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLevelRow('Entry', entryPrice, Colors.white),
          _buildLevelRow('Stop Loss (3%)', sl, Colors.red),
          _buildLevelRow('Take Profit 1 (5%)', tp1, Colors.green),
          _buildLevelRow('Take Profit 2 (10%)', tp2, Colors.green.shade700),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gunakan trailing stop untuk maximize profit saat trend continues',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelRow(String label, double price, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
          Text(
            '\$${price.toStringAsFixed(price > 100 ? 2 : 4)}',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard(bool isLong) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                'Risk Management',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRiskPoint('✓ Gunakan max 2-5x leverage untuk follow trend'),
          _buildRiskPoint('✓ Entry bertahap (scale in) saat trend confirmed'),
          _buildRiskPoint('✓ Set trailing stop untuk protect profit'),
          _buildRiskPoint('✓ Exit immediately jika trend reversal signal muncul'),
          _buildRiskPoint('✓ Watch for volume decrease sebagai early warning'),
        ],
      ),
    );
  }

  Widget _buildRiskPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          height: 1.4,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'HOT':
        return Colors.red;
      case 'STRONG':
        return Colors.orange;
      case 'MODERATE':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}

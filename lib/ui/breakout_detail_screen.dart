import 'package:flutter/material.dart';
import '../models/coin_data.dart';

class BreakoutDetailScreen extends StatelessWidget {
  final CoinData coin;

  const BreakoutDetailScreen({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusEmoji;
    String statusDescription;

    final isLong = coin.breakoutDirection == 'LONG';
    final baseStatus = coin.breakoutStatus
        .replaceAll('_LONG', '')
        .replaceAll('_SHORT', '');
    final directionText = isLong ? 'LONG (Buy)' : 'SHORT (Sell)';

    switch (baseStatus) {
      case 'BREAKOUT':
        statusColor = isLong ? Colors.green : Colors.red;
        statusEmoji = isLong ? '🚀' : '📉';
        statusDescription = isLong
            ? 'Breakout dikonfirmasi dengan volume spike!'
            : 'Breakdown dikonfirmasi dengan volume spike!';
        break;
      case 'TESTING':
        statusColor = isLong ? Colors.green.shade300 : Colors.red.shade300;
        statusEmoji = isLong ? '🔸' : '🔻';
        statusDescription = isLong
            ? 'Testing resistance - tunggu konfirmasi'
            : 'Testing support - tunggu konfirmasi';
        break;
      default:
        statusColor = Colors.grey;
        statusEmoji = '⏳';
        statusDescription = isLong
            ? 'Watching untuk potensi breakout'
            : 'Watching untuk potensi breakdown';
    }

    return Scaffold(
      appBar: AppBar(title: Text(coin.symbol), elevation: 2),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Header
          Card(
            color: statusColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(statusEmoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$directionText - ${baseStatus.toUpperCase()}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                            Text(
                              statusDescription,
                              style: TextStyle(
                                fontSize: 14,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTile(
                          'Price',
                          '\$${coin.price.toStringAsFixed(4)}',
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoTile(
                          '24h Change',
                          '${coin.priceChangePercent >= 0 ? '+' : ''}${coin.priceChangePercent.toStringAsFixed(2)}%',
                          coin.priceChangePercent >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoTile(
                          'Score',
                          coin.breakoutScore.toStringAsFixed(0),
                          statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Timeframe Analysis
          _buildSectionTitle('📊 Timeframe Analysis (15m + 1h)'),
          const SizedBox(height: 8),
          ...coin.breakoutTfScores.map((tfScore) {
            final features = coin.breakoutFeatures;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tfScore.tf.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Score: ${tfScore.score.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (features != null) ...[
                      const SizedBox(height: 12),
                      _buildFeatureRow(
                        'RSI',
                        tfScore.rsi.toStringAsFixed(1),
                        Colors.blue,
                      ),
                      _buildFeatureRow(
                        'EMA Distance',
                        '${(features.overExtEma * 100).toStringAsFixed(2)}%',
                        features.overExtEma > 0 ? Colors.green : Colors.red,
                      ),
                      _buildFeatureRow(
                        'Volume Trend',
                        features.volumeDeclineRatio < -0.3
                            ? 'Spike! 📊'
                            : features.volumeDeclineRatio < 0
                            ? 'Rising'
                            : 'Declining',
                        features.volumeDeclineRatio < -0.3
                            ? Colors.purple
                            : features.volumeDeclineRatio < 0
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),

          // Breakout Features
          if (coin.breakoutFeatures != null) ...[
            _buildSectionTitle('🎯 Breakout Signals'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSignalItem(
                      coin.breakoutFeatures!.overExtEma > 0.01,
                      'Above EMA',
                      'Price trading above moving averages',
                    ),
                    _buildSignalItem(
                      coin.breakoutFeatures!.volumeDeclineRatio < -0.3,
                      'Volume Spike',
                      'Volume significantly higher than average',
                    ),
                    _buildSignalItem(
                      coin.breakoutFeatures!.rsi > 50,
                      'Bullish Momentum',
                      'RSI confirming upward momentum',
                    ),
                    _buildSignalItem(
                      !coin.breakoutFeatures!.isAboveUpperBand,
                      'Room to Run',
                      'Not yet overextended, space for continuation',
                    ),
                    _buildSignalItem(
                      coin.breakoutFeatures!.rejectionWickRatio < 0.3,
                      'Clean Breakout',
                      'Minimal rejection, bulls in control',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Trading Guide
          _buildSectionTitle('📖 Trading Guide'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (coin.breakoutStatus == 'BREAKOUT') ...[
                    _buildGuideItem(
                      '✅',
                      'Entry',
                      'Breakout dikonfirmasi! Entry pada pullback kecil atau market order',
                      Colors.green,
                    ),
                    _buildGuideItem(
                      '🎯',
                      'Target',
                      'Target 1: +2-3% | Target 2: +5-7% | Target 3: Trailing stop',
                      Colors.blue,
                    ),
                    _buildGuideItem(
                      '🛡️',
                      'Stop Loss',
                      'Di bawah resistance yang di-breakout (~2-3%)',
                      Colors.red,
                    ),
                  ] else if (coin.breakoutStatus == 'TESTING') ...[
                    _buildGuideItem(
                      '⏳',
                      'Wait',
                      'Tunggu konfirmasi breakout dengan volume spike',
                      Colors.orange,
                    ),
                    _buildGuideItem(
                      '👀',
                      'Watch For',
                      'Volume spike + candle close di atas resistance',
                      Colors.blue,
                    ),
                  ] else ...[
                    _buildGuideItem(
                      '📋',
                      'Monitor',
                      'Tambahkan ke watchlist, tunggu harga mendekati resistance',
                      Colors.grey,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Strategy Explanation
          _buildSectionTitle('💡 Breakout Hunter Strategy'),
          const SizedBox(height: 8),
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Konsep Strategi:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isLong) ...[
                    _buildStrategyPoint(
                      '1️⃣',
                      'Price breaks above resistance',
                      'Harga menembus level resistance dari highs sebelumnya',
                    ),
                    _buildStrategyPoint(
                      '2️⃣',
                      'Volume confirms breakout',
                      'Volume spike (>1.5-2x average) mengkonfirmasi validitas breakout',
                    ),
                    _buildStrategyPoint(
                      '3️⃣',
                      'Momentum in bullish zone',
                      'RSI > 50 menunjukkan momentum bullish, tapi belum overbought',
                    ),
                    _buildStrategyPoint(
                      '4️⃣',
                      'Clean breakout structure',
                      'Candle bersih tanpa rejection wick besar = bulls in control',
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.amber.shade800),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Best Entry: Saat status BREAKOUT dengan volume spike tinggi',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    _buildStrategyPoint(
                      '1️⃣',
                      'Price breaks below support',
                      'Harga menembus level support dari lows sebelumnya',
                    ),
                    _buildStrategyPoint(
                      '2️⃣',
                      'Volume confirms breakdown',
                      'Volume spike (>1.5-2x average) mengkonfirmasi validitas breakdown',
                    ),
                    _buildStrategyPoint(
                      '3️⃣',
                      'Momentum in bearish zone',
                      'RSI < 50 menunjukkan momentum bearish, tapi belum oversold',
                    ),
                    _buildStrategyPoint(
                      '4️⃣',
                      'Clean breakdown structure',
                      'Candle bersih tanpa rejection wick besar = bears in control',
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.red.shade800),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Best Entry: Saat status BREAKOUT SHORT dengan volume spike tinggi',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.red.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Risk Management
          _buildSectionTitle('⚠️ Risk Management'),
          const SizedBox(height: 8),
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRiskPoint(
                    '🚫',
                    'False Breakout Risk',
                    'Tidak semua breakout valid - tunggu konfirmasi volume',
                  ),
                  _buildRiskPoint(
                    '📉',
                    'Stop Loss Mandatory',
                    'Selalu pasang SL di bawah resistance level (~2-3%)',
                  ),
                  _buildRiskPoint(
                    '💰',
                    'Position Sizing',
                    'Gunakan 1-2% capital per trade, jangan FOMO',
                  ),
                  _buildRiskPoint(
                    '⏰',
                    'Time Factor',
                    'Breakout terbaik early morning atau saat volume tinggi',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red.shade800),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hindari entry saat RSI > 75 atau status TESTING tanpa volume',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.red.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildFeatureRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalItem(bool isActive, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            color: isActive ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.green.shade800 : Colors.grey[700],
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(
    String emoji,
    String title,
    String description,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyPoint(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskPoint(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/coin_data.dart';

class CoinDetailScreen extends StatelessWidget {
  final CoinData coin;

  const CoinDetailScreen({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    final features = coin.features;

    return Scaffold(
      appBar: AppBar(
        title: Text(coin.symbol.replaceAll('USDT', '')),
        actions: [
          Chip(
            label: Text(
              coin.status,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: _getStatusColor(coin.status),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: features == null
          ? const Center(child: Text('No features data available'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Current Price', style: TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${coin.price > 1 ? coin.price.toStringAsFixed(2) : coin.price.toStringAsFixed(5)}',
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('24h Change', style: TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${coin.priceChangePercent.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: coin.priceChangePercent >= 0 ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetric('Score', coin.score.toStringAsFixed(0), Colors.blue),
                              _buildMetric('Basis', '${coin.basisSpread.toStringAsFixed(2)}%', 
                                coin.basisSpread > 1 ? Colors.red : Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reversal Analysis Card
                  Card(
                    color: _getReversalColor().withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(_getReversalIcon(), color: _getReversalColor(), size: 28),
                              const SizedBox(width: 8),
                              Text(
                                'Analisis Reversal',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _getReversalColor(),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildReversalAnalysis(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Indicators Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Technical Indicators',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Divider(height: 24),
                          _buildIndicatorRow('RSI', features.rsi.toStringAsFixed(1), 
                            features.rsi > 70 ? Colors.red : features.rsi < 30 ? Colors.green : Colors.grey),
                          _buildIndicatorRow('EMA Overextension', '${(features.overExtEma * 100).toStringAsFixed(2)}%',
                            features.overExtEma > 0.03 ? Colors.red : Colors.grey),
                          _buildIndicatorRow('VWAP Overextension', '${(features.overExtVwap * 100).toStringAsFixed(2)}%',
                            features.overExtVwap > 0.03 ? Colors.red : Colors.grey),
                          _buildIndicatorRow('Above Upper BB', features.isAboveUpperBand ? 'Yes' : 'No',
                            features.isAboveUpperBand ? Colors.red : Colors.grey),
                          _buildIndicatorRow('Funding Rate', '${(features.fundingRate * 100).toStringAsFixed(3)}%',
                            features.fundingRate > 0.01 ? Colors.orange : Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Structure Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Market Structure',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Divider(height: 24),
                          _buildStructureRow('Breakdown', features.isBreakdown),
                          _buildStructureRow('In Retest Zone', features.isRetest),
                          _buildStructureRow('Retest Failed', features.isRetestFail),
                          if (features.nearestSupport != null)
                            _buildIndicatorRow('Nearest Support', '\$${features.nearestSupport!.toStringAsFixed(2)}', Colors.blue),
                          if (features.distToSupportATR != null)
                            _buildIndicatorRow('Distance to Support', '${features.distToSupportATR!.toStringAsFixed(2)} ATR', Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Score Components Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Score Breakdown',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Divider(height: 24),
                          _buildScoreBar('Overextension', features.pctChange24h, 30),
                          _buildScoreBar('Exhaustion', features.rsi > 70 ? 15 : 0, 25),
                          _buildScoreBar('Structure', features.isBreakdown ? 15 : 0, 25),
                          const SizedBox(height: 8),
                          Text(
                            'Total Score: ${coin.score.toStringAsFixed(0)}/100',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildReversalAnalysis() {
    final features = coin.features!;
    final shortSignals = <String>[];
    final longSignals = <String>[];
    
    // SHORT signals
    if (features.rsi > 70) shortSignals.add('RSI overbought (${features.rsi.toStringAsFixed(0)})');
    if (features.overExtEma > 0.05) shortSignals.add('Overextended dari EMA50 (${(features.overExtEma * 100).toStringAsFixed(1)}%)');
    if (features.isAboveUpperBand) shortSignals.add('Harga di atas Bollinger Band atas');
    if (features.isBreakdown) shortSignals.add('Breakdown dari support terdeteksi');
    if (features.pctChange24h > 20) shortSignals.add('Pump besar 24h (${features.pctChange24h.toStringAsFixed(1)}%)');
    if (coin.basisSpread > 1.5) shortSignals.add('Basis spread tinggi (${coin.basisSpread.toStringAsFixed(2)}%)');
    
    // LONG signals
    if (features.rsi < 30) longSignals.add('RSI oversold (${features.rsi.toStringAsFixed(0)})');
    if (features.overExtEma < -0.05) longSignals.add('Underextended dari EMA50');
    if (features.isRetest && !features.isRetestFail) longSignals.add('Retest support yang valid');
    if (features.pctChange24h < -10) longSignals.add('Dump besar 24h (${features.pctChange24h.toStringAsFixed(1)}%)');

    final shortScore = shortSignals.length;
    final longScore = longSignals.length;

    String recommendation;
    String reasoning;
    
    if (shortScore > longScore && shortScore >= 3) {
      recommendation = '🔴 HIGH PROBABILITY SHORT (2x Leverage)';
      reasoning = 'Banyak indikator menunjukkan overextension dan potensi reversal turun.';
    } else if (shortScore >= 2) {
      recommendation = '🟠 MODERATE SHORT SETUP';
      reasoning = 'Ada beberapa sinyal short, tapi belum terlalu kuat. Tunggu konfirmasi lebih.';
    } else if (longScore > shortScore && longScore >= 2) {
      recommendation = '🟢 LONG OPPORTUNITY';
      reasoning = 'Lebih cocok untuk long daripada short.';
    } else {
      recommendation = '⚪ NEUTRAL / AVOID';
      reasoning = 'Tidak ada setup yang jelas. Tunggu signal yang lebih kuat.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recommendation,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          reasoning,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        
        if (shortSignals.isNotEmpty) ...[
          const Text('SHORT Signals:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 8),
          ...shortSignals.map((signal) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.arrow_downward, size: 16, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text(signal, style: const TextStyle(fontSize: 13))),
              ],
            ),
          )),
          const SizedBox(height: 12),
        ],
        
        if (longSignals.isNotEmpty) ...[
          const Text('LONG Signals:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 8),
          ...longSignals.map((signal) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.arrow_upward, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text(signal, style: const TextStyle(fontSize: 13))),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Color _getReversalColor() {
    final features = coin.features!;
    final shortSignals = (features.rsi > 70 ? 1 : 0) +
        (features.overExtEma > 0.05 ? 1 : 0) +
        (features.isAboveUpperBand ? 1 : 0) +
        (features.isBreakdown ? 1 : 0) +
        (features.pctChange24h > 20 ? 1 : 0);
    
    if (shortSignals >= 3) return Colors.red;
    if (shortSignals >= 2) return Colors.orange;
    return Colors.grey;
  }

  IconData _getReversalIcon() {
    final features = coin.features!;
    final shortSignals = (features.rsi > 70 ? 1 : 0) +
        (features.overExtEma > 0.05 ? 1 : 0) +
        (features.isAboveUpperBand ? 1 : 0) +
        (features.isBreakdown ? 1 : 0) +
        (features.pctChange24h > 20 ? 1 : 0);
    
    if (shortSignals >= 3) return Icons.trending_down;
    if (shortSignals >= 2) return Icons.warning;
    return Icons.info_outline;
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildIndicatorRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildStructureRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, double value, double max) {
    final percentage = (value / max).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              Text('${value.toStringAsFixed(0)}/$max', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage > 0.7 ? Colors.red : percentage > 0.4 ? Colors.orange : Colors.blue,
            ),
          ),
        ],
      ),
    );
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
}

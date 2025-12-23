import 'package:flutter/material.dart';
import '../models/coin_data.dart';
import '../services/trade_service.dart';
import '../scoring/features.dart';

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
          if (coin.confluenceCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getConfluenceColor(coin.confluenceCount),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${coin.confluenceCount}TF',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          Chip(
            label: Text(
              coin.status,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: _getStatusColor(coin.status),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: features == null
          ? const Center(child: Text('No features data available'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Summary Card
                  _buildSummaryCard(context),
                  const SizedBox(height: 12),

                  // Price & Market Data
                  _buildPriceCard(context),
                  const SizedBox(height: 12),

                  // Multi-TF Confluence Card
                  if (coin.tfScores.isNotEmpty) ...[
                    _buildMultiTFCard(context),
                    const SizedBox(height: 12),
                  ],

                  // Momentum Loss Detection Card (NEW!)
                  _buildMomentumLossCard(context),
                  const SizedBox(height: 12),

                  // Entry Signals Card
                  _buildEntrySignalsCard(context),
                  const SizedBox(height: 12),

                  // Technical Indicators Card
                  _buildIndicatorsCard(context),
                  const SizedBox(height: 12),

                  // Momentum & Volatility
                  _buildMomentumCard(context),
                  const SizedBox(height: 12),

                  // Market Structure Card
                  _buildStructureCard(context),
                  const SizedBox(height: 12),

                  // Entry Levels Card
                  _buildEntryLevelsCard(context),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
      floatingActionButton: _buildEntryButton(context),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final f = coin.features!;
    final isStrongShort =
        coin.status == 'TRIGGER' ||
        (coin.confluenceCount >= 2 && coin.score >= 50);

    return Card(
      color: isStrongShort ? Colors.red.withOpacity(0.15) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isStrongShort ? Icons.local_fire_department : Icons.analytics,
                  color: isStrongShort ? Colors.red : Colors.grey,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isStrongShort
                            ? 'SHORT OPPORTUNITY'
                            : 'Analysis Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isStrongShort ? Colors.red : Colors.white,
                        ),
                      ),
                      Text(
                        _getSignalSummary(f),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(coin.score),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${coin.score.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'SCORE',
                        style: TextStyle(fontSize: 9, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Quick Stats Row
            Row(
              children: [
                _buildQuickStat(
                  'RSI',
                  f.rsi.toStringAsFixed(0),
                  f.rsi > 70
                      ? Colors.red
                      : f.rsi < 30
                      ? Colors.green
                      : Colors.grey,
                ),
                _buildQuickStat(
                  'EMA',
                  '${(f.overExtEma * 100).toStringAsFixed(1)}%',
                  f.overExtEma > 0.03 ? Colors.red : Colors.grey,
                ),
                _buildQuickStat(
                  '24h',
                  '${f.pctChange24h >= 0 ? '+' : ''}${f.pctChange24h.toStringAsFixed(1)}%',
                  f.pctChange24h > 20
                      ? Colors.red
                      : f.pctChange24h < -10
                      ? Colors.green
                      : Colors.grey,
                ),
                _buildQuickStat(
                  'TF',
                  '${coin.confluenceCount}/2',
                  _getConfluenceColor(coin.confluenceCount),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  String _getSignalSummary(MarketFeatures f) {
    List<String> signals = [];
    if (f.rsi > 70) signals.add('Overbought');
    if (f.overExtEma > 0.03) signals.add('Extended');
    if (f.isAboveUpperBand) signals.add('Above BB');
    if (f.isBreakdown) signals.add('Breakdown');
    if (coin.confluenceCount >= 2) signals.add('Multi-TF');
    return signals.isEmpty ? 'No strong signals' : signals.join(' • ');
  }

  Widget _buildPriceCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_money, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Price & Market',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Price',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '\$${coin.price > 1 ? coin.price.toStringAsFixed(2) : coin.price.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '24h Change',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${coin.priceChangePercent >= 0 ? '+' : ''}${coin.priceChangePercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: coin.priceChangePercent >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'Funding',
                    '${(coin.fundingRate * 100).toStringAsFixed(3)}%',
                    coin.fundingRate > 0.01 ? Colors.orange : Colors.grey,
                    Icons.percent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    'Basis',
                    '${coin.basisSpread.toStringAsFixed(2)}%',
                    coin.basisSpread > 1 ? Colors.red : Colors.grey,
                    Icons.swap_vert,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiTFCard(BuildContext context) {
    return Card(
      color: coin.confluenceCount >= 2 ? Colors.green.withOpacity(0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  coin.confluenceCount >= 2 ? Icons.verified : Icons.timeline,
                  color: _getConfluenceColor(coin.confluenceCount),
                ),
                const SizedBox(width: 8),
                Text(
                  'Multi-TF Analysis (1m + 5m)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getConfluenceColor(coin.confluenceCount),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getConfluenceColor(coin.confluenceCount),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    coin.confluenceCount >= 2
                        ? 'ALIGNED ✓'
                        : coin.confluenceCount >= 1
                        ? 'PARTIAL'
                        : 'WEAK',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // TF Score bars with more detail
            ...coin.tfScores.map((ts) => _buildTFScoreRow(ts)),
            if (coin.tfFeatures.isNotEmpty) ...[
              const Divider(height: 24),
              const Text(
                'Signal Details per Timeframe:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              ...coin.tfFeatures.map((tf) => _buildTFFeatureRow(tf)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTFScoreRow(TimeframeScore ts) {
    final pct = (ts.score / 100).clamp(0.0, 1.0);
    final isHot = ts.score >= 50;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isHot ? Colors.red : Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ts.tf.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade800,
                    valueColor: AlwaysStoppedAnimation(
                      pct >= 0.6
                          ? Colors.red
                          : pct >= 0.4
                          ? Colors.orange
                          : Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${ts.score.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isHot ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildMiniChip(
                'RSI ${ts.rsi.toStringAsFixed(0)}',
                ts.rsi > 70
                    ? Colors.red
                    : ts.rsi < 30
                    ? Colors.green
                    : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTFFeatureRow(TimeframeFeatures tf) {
    final signals = <Widget>[];
    if (tf.rsi > 70)
      signals.add(
        _buildMiniChip('RSI ${tf.rsi.toStringAsFixed(0)}', Colors.red),
      );
    if (tf.rsi > 60 && tf.rsi <= 70)
      signals.add(
        _buildMiniChip('RSI ${tf.rsi.toStringAsFixed(0)}', Colors.orange),
      );
    if (tf.overExtEma > 0.03)
      signals.add(
        _buildMiniChip(
          'EMA +${(tf.overExtEma * 100).toStringAsFixed(1)}%',
          Colors.red,
        ),
      );
    if (tf.overExtEma > 0.02 && tf.overExtEma <= 0.03)
      signals.add(
        _buildMiniChip(
          'EMA +${(tf.overExtEma * 100).toStringAsFixed(1)}%',
          Colors.orange,
        ),
      );
    if (tf.isAboveUpperBB) signals.add(_buildMiniChip('Above BB', Colors.red));
    if (tf.isBreakdown) signals.add(_buildMiniChip('BREAKDOWN', Colors.purple));

    final isAligned = tf.rsi > 60 || tf.overExtEma > 0.02 || tf.isAboveUpperBB;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isAligned
            ? Colors.green.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAligned
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: isAligned ? Colors.green : Colors.grey.shade700,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              tf.tf.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            isAligned ? Icons.check_circle : Icons.remove_circle_outline,
            size: 18,
            color: isAligned ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: signals.isEmpty
                ? Text(
                    'No signals',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  )
                : Wrap(spacing: 6, runSpacing: 4, children: signals),
          ),
        ],
      ),
    );
  }

  Widget _buildMomentumLossCard(BuildContext context) {
    final f = coin.features!;
    final hasAnyMomentumSignal =
        f.isLosingMomentum ||
        f.hasRsiDivergence ||
        f.hasVolumeDivergence ||
        f.rsiSlope < -2;

    // Count momentum loss signals
    int signalCount = 0;
    if (f.hasRsiDivergence) signalCount++;
    if (f.hasVolumeDivergence) signalCount++;
    if (f.rsiSlope < -2) signalCount++;
    if (f.momentumSlope < 0) signalCount++;

    return Card(
      color: f.isLosingMomentum ? Colors.purple.withOpacity(0.15) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  f.isLosingMomentum ? Icons.flash_off : Icons.flash_on,
                  color: f.isLosingMomentum ? Colors.purple : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Momentum Analysis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: f.isLosingMomentum ? Colors.purple : Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: f.isLosingMomentum
                        ? Colors.purple
                        : hasAnyMomentumSignal
                        ? Colors.orange
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    f.isLosingMomentum
                        ? 'LOSING ⚡'
                        : hasAnyMomentumSignal
                        ? '$signalCount SIGNAL'
                        : 'STRONG',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            // RSI Divergence
            _buildMomentumSignalRow(
              'RSI Divergence',
              f.hasRsiDivergence,
              'Price Higher High, RSI Lower High',
              Icons.call_split,
              Colors.orange,
            ),
            // Volume Divergence
            _buildMomentumSignalRow(
              'Volume Divergence',
              f.hasVolumeDivergence,
              'Price rising but volume declining',
              Icons.bar_chart,
              Colors.blue,
            ),
            // RSI Slope
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(
                    f.rsiSlope < -2
                        ? Icons.south
                        : f.rsiSlope > 2
                        ? Icons.north
                        : Icons.remove,
                    size: 20,
                    color: f.rsiSlope < -2
                        ? Colors.green
                        : f.rsiSlope > 2
                        ? Colors.red
                        : Colors.grey,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RSI Slope',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          f.rsiSlope < -2
                              ? 'Declining (bearish)'
                              : f.rsiSlope > 2
                              ? 'Rising (bullish)'
                              : 'Neutral',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    f.rsiSlope.toStringAsFixed(2),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: f.rsiSlope < -2
                          ? Colors.green
                          : f.rsiSlope > 2
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Momentum Slope
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(
                    f.momentumSlope < 0
                        ? Icons.trending_down
                        : Icons.trending_up,
                    size: 20,
                    color: f.momentumSlope < 0 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Price Momentum',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          f.momentumSlope < 0
                              ? 'Decelerating (slowing)'
                              : 'Accelerating',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    f.momentumSlope.toStringAsFixed(3),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: f.momentumSlope < 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            // Volume Decline Ratio
            if (f.volumeDeclineRatio < 1.0)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(Icons.trending_down, size: 20, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Volume Ratio',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Recent vs Average volume',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${(f.volumeDeclineRatio * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: f.volumeDeclineRatio < 0.7
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMomentumSignalRow(
    String label,
    bool isActive,
    String desc,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            isActive ? icon : Icons.remove_circle_outline,
            size: 20,
            color: isActive ? color : Colors.grey.shade600,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isActive)
                  Text(
                    desc,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isActive ? color : Colors.grey.shade700,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isActive ? 'DETECTED' : 'NO',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntrySignalsCard(BuildContext context) {
    final f = coin.features!;
    final signals = <Map<String, dynamic>>[];

    // RSI signals
    if (f.rsi > 80) {
      signals.add({
        'icon': Icons.warning,
        'text': 'RSI Extreme Overbought (${f.rsi.toStringAsFixed(0)})',
        'color': Colors.red,
        'strength': 3,
      });
    } else if (f.rsi > 70) {
      signals.add({
        'icon': Icons.trending_up,
        'text': 'RSI Overbought (${f.rsi.toStringAsFixed(0)})',
        'color': Colors.orange,
        'strength': 2,
      });
    } else if (f.rsi > 60) {
      signals.add({
        'icon': Icons.info,
        'text': 'RSI Elevated (${f.rsi.toStringAsFixed(0)})',
        'color': Colors.yellow,
        'strength': 1,
      });
    }

    // EMA extension
    if (f.overExtEma > 0.08) {
      signals.add({
        'icon': Icons.bolt,
        'text':
            'Extreme EMA Extension +${(f.overExtEma * 100).toStringAsFixed(1)}%',
        'color': Colors.red,
        'strength': 3,
      });
    } else if (f.overExtEma > 0.05) {
      signals.add({
        'icon': Icons.trending_up,
        'text':
            'High EMA Extension +${(f.overExtEma * 100).toStringAsFixed(1)}%',
        'color': Colors.orange,
        'strength': 2,
      });
    } else if (f.overExtEma > 0.03) {
      signals.add({
        'icon': Icons.arrow_upward,
        'text': 'EMA Extended +${(f.overExtEma * 100).toStringAsFixed(1)}%',
        'color': Colors.yellow,
        'strength': 1,
      });
    }

    // Bollinger Bands
    if (f.isAboveUpperBand) {
      signals.add({
        'icon': Icons.vertical_align_top,
        'text': 'Price Above Upper Bollinger Band',
        'color': Colors.orange,
        'strength': 2,
      });
    }

    // 24h pump
    if (f.pctChange24h > 50) {
      signals.add({
        'icon': Icons.rocket_launch,
        'text': 'Massive Pump +${f.pctChange24h.toStringAsFixed(1)}%',
        'color': Colors.red,
        'strength': 3,
      });
    } else if (f.pctChange24h > 30) {
      signals.add({
        'icon': Icons.trending_up,
        'text': 'Strong Pump +${f.pctChange24h.toStringAsFixed(1)}%',
        'color': Colors.orange,
        'strength': 2,
      });
    } else if (f.pctChange24h > 15) {
      signals.add({
        'icon': Icons.arrow_upward,
        'text': 'Good Pump +${f.pctChange24h.toStringAsFixed(1)}%',
        'color': Colors.yellow,
        'strength': 1,
      });
    }

    // Basis spread
    if (coin.basisSpread > 3) {
      signals.add({
        'icon': Icons.swap_vert,
        'text': 'Extreme Basis Spread ${coin.basisSpread.toStringAsFixed(2)}%',
        'color': Colors.red,
        'strength': 3,
      });
    } else if (coin.basisSpread > 1.5) {
      signals.add({
        'icon': Icons.swap_vert,
        'text': 'High Basis Spread ${coin.basisSpread.toStringAsFixed(2)}%',
        'color': Colors.orange,
        'strength': 2,
      });
    }

    // Funding
    if (coin.fundingRate > 0.02) {
      signals.add({
        'icon': Icons.percent,
        'text': 'High Funding ${(coin.fundingRate * 100).toStringAsFixed(3)}%',
        'color': Colors.orange,
        'strength': 2,
      });
    }

    // Breakdown
    if (f.isBreakdown) {
      signals.add({
        'icon': Icons.trending_down,
        'text': 'Structure Breakdown Detected',
        'color': Colors.purple,
        'strength': 2,
      });
    }

    // === MOMENTUM LOSS SIGNALS ===
    if (f.isLosingMomentum) {
      signals.add({
        'icon': Icons.flash_off,
        'text': 'LOSING MOMENTUM - Reversal Likely',
        'color': Colors.purple,
        'strength': 3,
      });
    }
    if (f.hasRsiDivergence) {
      signals.add({
        'icon': Icons.call_split,
        'text': 'RSI Bearish Divergence (Price HH, RSI LH)',
        'color': Colors.orange,
        'strength': 3,
      });
    }
    if (f.hasVolumeDivergence) {
      signals.add({
        'icon': Icons.bar_chart,
        'text': 'Volume Divergence (Price ↑, Volume ↓)',
        'color': Colors.blue,
        'strength': 2,
      });
    }
    if (f.rsiSlope < -3) {
      signals.add({
        'icon': Icons.south,
        'text': 'RSI Declining Fast (${f.rsiSlope.toStringAsFixed(1)})',
        'color': Colors.orange,
        'strength': 2,
      });
    }

    // Multi-TF confluence
    if (coin.confluenceCount >= 2) {
      signals.add({
        'icon': Icons.verified,
        'text': '${coin.confluenceCount}TF Confluence Aligned!',
        'color': Colors.green,
        'strength': 3,
      });
    }

    signals.sort(
      (a, b) => (b['strength'] as int).compareTo(a['strength'] as int),
    );

    final totalStrength = signals.fold<int>(
      0,
      (sum, s) => sum + (s['strength'] as int),
    );
    final isStrong = totalStrength >= 6;

    return Card(
      color: isStrong ? Colors.red.withOpacity(0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isStrong ? Icons.local_fire_department : Icons.analytics,
                  color: isStrong ? Colors.red : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  isStrong ? 'STRONG SHORT SIGNALS' : 'Entry Signals',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isStrong ? Colors.red : Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isStrong ? Colors.red : Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$totalStrength pts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            if (signals.isEmpty)
              const Text(
                'No significant signals detected',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...signals.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        s['icon'] as IconData,
                        size: 18,
                        color: s['color'] as Color,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          s['text'] as String,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      ...List.generate(
                        s['strength'] as int,
                        (_) => Icon(
                          Icons.star,
                          size: 12,
                          color: s['color'] as Color,
                        ),
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

  Widget _buildIndicatorsCard(BuildContext context) {
    final f = coin.features!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Technical Indicators',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildIndicatorRow(
              'RSI (14)',
              f.rsi,
              0,
              100,
              f.rsi > 70
                  ? Colors.red
                  : f.rsi < 30
                  ? Colors.green
                  : Colors.blue,
            ),
            _buildIndicatorRow(
              'EMA Overext',
              f.overExtEma * 100,
              0,
              15,
              f.overExtEma > 0.05
                  ? Colors.red
                  : f.overExtEma > 0.03
                  ? Colors.orange
                  : Colors.blue,
            ),
            _buildIndicatorRow(
              'VWAP Overext',
              f.overExtVwap * 100,
              0,
              10,
              f.overExtVwap > 0.03 ? Colors.red : Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildRow(
              'Above Upper BB',
              f.isAboveUpperBand ? 'Yes' : 'No',
              f.isAboveUpperBand ? Colors.red : Colors.grey,
            ),
            _buildRow(
              'Funding Rate',
              '${(f.fundingRate * 100).toStringAsFixed(3)}%',
              f.fundingRate > 0.01 ? Colors.orange : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorRow(
    String label,
    double value,
    double min,
    double max,
    Color color,
  ) {
    final pct = ((value - min) / (max - min)).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              Text(
                value.toStringAsFixed(1),
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: Colors.grey.shade800,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMomentumCard(BuildContext context) {
    final f = coin.features!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Momentum & Volatility',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMomentumTile(
                    '24h Change',
                    '${f.pctChange24h >= 0 ? '+' : ''}${f.pctChange24h.toStringAsFixed(2)}%',
                    f.pctChange24h > 20
                        ? Colors.red
                        : f.pctChange24h < -10
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMomentumTile(
                    'Funding',
                    '${(f.fundingRate * 100).toStringAsFixed(3)}%',
                    f.fundingRate > 0.01 ? Colors.orange : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMomentumTile(
                    'Basis',
                    '${coin.basisSpread.toStringAsFixed(2)}%',
                    coin.basisSpread > 1.5 ? Colors.red : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMomentumTile(
                    'Score',
                    coin.score.toStringAsFixed(0),
                    _getScoreColor(coin.score),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMomentumTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildStructureCard(BuildContext context) {
    final f = coin.features!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.architecture, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Market Structure',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildStructureRow(
              'Breakdown',
              f.isBreakdown,
              'Structure broken down',
            ),
            _buildStructureRow(
              'In Retest Zone',
              f.isRetest,
              'Price retesting key level',
            ),
            _buildStructureRow(
              'Retest Failed',
              f.isRetestFail,
              'Retest rejection confirmed',
            ),
            const SizedBox(height: 8),
            if (f.nearestSupport != null)
              _buildRow(
                'Nearest Support',
                '\$${f.nearestSupport!.toStringAsFixed(f.nearestSupport! > 1 ? 2 : 6)}',
                Colors.blue,
              ),
            if (f.distToSupportATR != null)
              _buildRow(
                'Distance to Support',
                '${f.distToSupportATR!.toStringAsFixed(2)} ATR',
                f.distToSupportATR! < 1 ? Colors.green : Colors.grey,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStructureRow(String label, bool value, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: value ? Colors.green : Colors.grey.shade600,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (value)
                  Text(
                    desc,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryLevelsCard(BuildContext context) {
    final entryPrice = coin.price;
    final sl = entryPrice * 1.006;
    final tp1 = entryPrice * 0.992;
    final tp2 = entryPrice * 0.985;
    final tp3 = entryPrice * 0.975;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Suggested Entry Levels',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildLevelBar('Entry', entryPrice, Colors.white, 1.0),
            _buildLevelBar('SL (0.6%)', sl, Colors.red, 0.6),
            _buildLevelBar('TP1 (0.8%)', tp1, Colors.green.shade400, 0.8),
            _buildLevelBar('TP2 (1.5%)', tp2, Colors.green.shade600, 1.0),
            _buildLevelBar('TP3 (2.5%)', tp3, Colors.green.shade800, 1.0),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Risk : Reward', style: TextStyle(fontSize: 12)),
                  const Text(
                    '0.6% : 0.8% / 1.5% / 2.5%',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelBar(
    String label,
    double price,
    Color color,
    double opacity,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: color.withOpacity(opacity)),
            ),
          ),
          Expanded(
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '\$${price.toStringAsFixed(price > 1 ? 4 : 8)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
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

  Widget? _buildEntryButton(BuildContext context) {
    if (coin.status != 'TRIGGER' && coin.status != 'SETUP') return null;

    return FloatingActionButton.extended(
      onPressed: () => _showEntryDialog(context),
      backgroundColor: Colors.red,
      icon: const Icon(Icons.trending_down),
      label: Text(coin.status == 'TRIGGER' ? 'Entry SHORT 🔥' : 'Entry SHORT'),
    );
  }

  void _showEntryDialog(BuildContext context) {
    final entryPrice = coin.price;
    final sl = entryPrice * 1.006;
    final tp1 = entryPrice * 0.992;
    final tp2 = entryPrice * 0.985;
    final tp3 = entryPrice * 0.975;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.trending_down, color: Colors.red),
            const SizedBox(width: 8),
            Text('SHORT ${coin.symbol.replaceAll('USDT', '')}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(coin.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusColor(coin.status) == Colors.redAccent
                          ? Icons.local_fire_department
                          : Icons.auto_awesome,
                      color: _getStatusColor(coin.status),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${coin.status} | Score: ${coin.score.toStringAsFixed(0)} | ${coin.confluenceCount}TF',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(coin.status),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildDialogLevelRow('Entry', entryPrice),
              _buildDialogLevelRow('SL', sl, isLoss: true),
              _buildDialogLevelRow('TP1', tp1),
              _buildDialogLevelRow('TP2', tp2),
              _buildDialogLevelRow('TP3', tp3),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'R:R = 0.6% : 0.8% / 1.5% / 2.5%',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _submitEntry(context, entryPrice, sl, tp1, tp2, tp3);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm SHORT'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogLevelRow(
    String label,
    double price, {
    bool isLoss = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isLoss ? Colors.red : Colors.green,
            ),
          ),
          Text('\$${price.toStringAsFixed(price > 1 ? 4 : 8)}'),
        ],
      ),
    );
  }

  Future<void> _submitEntry(
    BuildContext context,
    double entryPrice,
    double sl,
    double tp1,
    double tp2,
    double tp3,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final reason =
          '${coin.status} | Score: ${coin.score.toStringAsFixed(0)} | ${coin.confluenceCount}TF | RSI: ${coin.features?.rsi.toStringAsFixed(0)}';
      await TradeService.createEntry(
        symbol: coin.symbol,
        isLong: false,
        entryPrice: entryPrice,
        stopLoss: sl,
        takeProfit1: tp1,
        takeProfit2: tp2,
        takeProfit3: tp3,
        entryReason: reason,
      );
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Entry ${coin.symbol} created'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
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

  Color _getConfluenceColor(int count) {
    if (count >= 2) return Colors.green;
    if (count >= 1) return Colors.orange;
    return Colors.grey;
  }

  Color _getScoreColor(double score) {
    if (score >= 60) return Colors.red;
    if (score >= 45) return Colors.orange;
    if (score >= 30) return Colors.blue;
    return Colors.grey;
  }
}

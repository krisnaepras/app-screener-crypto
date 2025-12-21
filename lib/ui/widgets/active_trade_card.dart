import 'package:flutter/material.dart';
import '../../models/trade_entry.dart';
import 'package:intl/intl.dart';

class ActiveTradeCard extends StatelessWidget {
  final TradeEntry entry;
  final VoidCallback onClose;

  const ActiveTradeCard({
    super.key,
    required this.entry,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(entry.entryTime);
    final currentPrice = entry.isLong
        ? entry.entryPrice * 1.002
        : entry.entryPrice * 0.998;
    final unrealizedPL = _calculateUnrealizedPL(currentPrice);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      entry.symbol,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: entry.isLong ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        entry.isLong ? 'LONG' : 'SHORT',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              timeAgo,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPriceInfo('Entry', entry.entryPrice),
                _buildPriceInfo('Current', currentPrice),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Unrealized P/L',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${unrealizedPL >= 0 ? '+' : ''}\$${unrealizedPL.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: unrealizedPL >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTargetProgress(),
            const SizedBox(height: 12),
            if (entry.entryReason.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.entryReason,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onClose,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Close Position'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;

    switch (entry.status) {
      case 'tp1_hit':
        color = Colors.green;
        text = 'TP1 Hit';
        break;
      case 'tp2_hit':
        color = Colors.green;
        text = 'TP2 Hit';
        break;
      case 'tp3_hit':
        color = Colors.green;
        text = 'TP3 Hit';
        break;
      default:
        color = Colors.blue;
        text = 'Active';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriceInfo(String label, double price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          '\$${price.toStringAsFixed(4)}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTargetProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTargetRow('SL', entry.stopLoss, Colors.red),
        const SizedBox(height: 8),
        _buildTargetRow(
          'TP1',
          entry.takeProfit1,
          Colors.green,
          hit: entry.status.contains('tp1'),
        ),
        const SizedBox(height: 4),
        _buildTargetRow(
          'TP2',
          entry.takeProfit2,
          Colors.green,
          hit: entry.status.contains('tp2'),
        ),
        const SizedBox(height: 4),
        _buildTargetRow(
          'TP3',
          entry.takeProfit3,
          Colors.green,
          hit: entry.status.contains('tp3'),
        ),
      ],
    );
  }

  Widget _buildTargetRow(
    String label,
    double price,
    Color color, {
    bool hit = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '\$${price.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        if (hit) const Icon(Icons.check_circle, color: Colors.green, size: 18),
      ],
    );
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  double _calculateUnrealizedPL(double currentPrice) {
    final diff = entry.isLong
        ? currentPrice - entry.entryPrice
        : entry.entryPrice - currentPrice;
    return diff * 10; // Assuming position size of 10
  }
}

import 'package:flutter/material.dart';
import '../../models/trade_entry.dart';
import 'package:intl/intl.dart';

class HistoryTradeCard extends StatelessWidget {
  final TradeEntry entry;

  const HistoryTradeCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isProfitable = entry.profitLoss != null && entry.profitLoss! > 0;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final plPercent = entry.currentProfitLossPercent;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: entry.isLong
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        entry.isLong ? 'LONG' : 'SHORT',
                        style: TextStyle(
                          color: entry.isLong ? Colors.green : Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isProfitable ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isProfitable ? '+' : ''}\$${entry.profitLoss!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${isProfitable ? '+' : ''}${plPercent.toStringAsFixed(2)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoColumn(
                    'Entry',
                    '\$${entry.entryPrice.toStringAsFixed(4)}',
                  ),
                ),
                Expanded(
                  child: _buildInfoColumn(
                    'Exit',
                    '\$${entry.exitPrice!.toStringAsFixed(4)}',
                  ),
                ),
                Expanded(child: _buildInfoColumn('Status', _getStatusText())),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Entry: ${dateFormat.format(entry.entryTime)}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.logout, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Exit: ${dateFormat.format(entry.exitTime!)}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  if (entry.entryReason.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            entry.entryReason,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _getStatusText() {
    switch (entry.status) {
      case 'closed':
        return 'Closed';
      case 'stopped':
        return 'Stop Loss';
      case 'tp1_hit':
        return 'TP1 Hit';
      case 'tp2_hit':
        return 'TP2 Hit';
      case 'tp3_hit':
        return 'TP3 Hit';
      default:
        return entry.status;
    }
  }
}

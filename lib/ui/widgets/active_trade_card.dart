import 'package:flutter/material.dart';
import '../../models/trade_entry.dart';
import 'package:intl/intl.dart';

class ActiveTradeCard extends StatefulWidget {
  final TradeEntry entry;
  final double? currentPrice; // Real-time price from websocket
  final VoidCallback onClose;

  const ActiveTradeCard({
    super.key,
    required this.entry,
    this.currentPrice,
    required this.onClose,
  });

  @override
  State<ActiveTradeCard> createState() => _ActiveTradeCardState();
}

class _ActiveTradeCardState extends State<ActiveTradeCard> {
  double? _previousPrice;
  bool _isPriceIncreasing = false;

  @override
  void didUpdateWidget(ActiveTradeCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detect price change direction for animation
    if (widget.currentPrice != null && oldWidget.currentPrice != null) {
      if (widget.currentPrice! > oldWidget.currentPrice!) {
        setState(() {
          _isPriceIncreasing = true;
          _previousPrice = oldWidget.currentPrice;
        });
      } else if (widget.currentPrice! < oldWidget.currentPrice!) {
        setState(() {
          _isPriceIncreasing = false;
          _previousPrice = oldWidget.currentPrice;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(widget.entry.entryTime);

    // Use real-time price if available, otherwise fallback to mock
    final currentPrice =
        widget.currentPrice ??
        (widget.entry.isLong
            ? widget.entry.entryPrice * 1.002
            : widget.entry.entryPrice * 0.998);

    final unrealizedPL = _calculateUnrealizedPL(currentPrice);
    final priceChangePercent =
        ((currentPrice - widget.entry.entryPrice) /
        widget.entry.entryPrice *
        100);

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
                      widget.entry.symbol,
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
                        color: widget.entry.isLong ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.entry.isLong ? 'LONG' : 'SHORT',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Real-time indicator
                    if (widget.currentPrice != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
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
                _buildPriceInfo('Entry', widget.entry.entryPrice),
                _buildPriceInfo(
                  'Current',
                  currentPrice,
                  priceChange: priceChangePercent,
                  isIncreasing: _previousPrice != null
                      ? currentPrice > _previousPrice!
                      : null,
                ),
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
            _buildTargetProgress(currentPrice),
            const SizedBox(height: 12),
            if (widget.entry.entryReason.isNotEmpty)
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
                        widget.entry.entryReason,
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
                onPressed: widget.onClose,
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

    switch (widget.entry.status) {
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

  Widget _buildPriceInfo(
    String label,
    double price, {
    double? priceChange,
    bool? isIncreasing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '\$${price.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            if (priceChange != null) ...[
              const SizedBox(width: 4),
              Icon(
                isIncreasing == true
                    ? Icons.arrow_upward
                    : isIncreasing == false
                    ? Icons.arrow_downward
                    : Icons.remove,
                size: 12,
                color: isIncreasing == true
                    ? Colors.green
                    : isIncreasing == false
                    ? Colors.red
                    : Colors.grey,
              ),
              Text(
                '${priceChange >= 0 ? '+' : ''}${priceChange.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 10,
                  color: priceChange >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTargetProgress(double currentPrice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTargetRow('SL', widget.entry.stopLoss, Colors.red, currentPrice),
        const SizedBox(height: 8),
        _buildTargetRow(
          'TP1',
          widget.entry.takeProfit1,
          Colors.green,
          currentPrice,
          hit: widget.entry.status.contains('tp1'),
        ),
        const SizedBox(height: 4),
        _buildTargetRow(
          'TP2',
          widget.entry.takeProfit2,
          Colors.green,
          currentPrice,
          hit: widget.entry.status.contains('tp2'),
        ),
        const SizedBox(height: 4),
        _buildTargetRow(
          'TP3',
          widget.entry.takeProfit3,
          Colors.green,
          currentPrice,
          hit: widget.entry.status.contains('tp3'),
        ),
      ],
    );
  }

  Widget _buildTargetRow(
    String label,
    double targetPrice,
    Color color,
    double currentPrice, {
    bool hit = false,
  }) {
    // Calculate progress towards target
    final isLong = widget.entry.isLong;
    final entry = widget.entry.entryPrice;
    final isStopLoss = label == 'SL';

    double progress = 0.0;
    if (isLong) {
      if (isStopLoss) {
        // For long SL, progress increases as price goes down
        progress = ((entry - currentPrice) / (entry - targetPrice)).clamp(
          0.0,
          1.0,
        );
      } else {
        // For long TP, progress increases as price goes up
        progress = ((currentPrice - entry) / (targetPrice - entry)).clamp(
          0.0,
          1.0,
        );
      }
    } else {
      if (isStopLoss) {
        // For short SL, progress increases as price goes up
        progress = ((currentPrice - entry) / (targetPrice - entry)).clamp(
          0.0,
          1.0,
        );
      } else {
        // For short TP, progress increases as price goes down
        progress = ((entry - currentPrice) / (entry - targetPrice)).clamp(
          0.0,
          1.0,
        );
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${targetPrice.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        color.withOpacity(0.7),
                      ),
                      minHeight: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (hit)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.check_circle, color: Colors.green, size: 18),
          ),
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
    final diff = widget.entry.isLong
        ? currentPrice - widget.entry.entryPrice
        : widget.entry.entryPrice - currentPrice;
    return diff * 10; // Assuming position size of 10
  }
}

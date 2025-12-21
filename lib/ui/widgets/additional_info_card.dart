import 'package:flutter/material.dart';

class AdditionalInfoCard extends StatelessWidget {
  final double rsi;
  final double priceChange;
  final double volume;

  const AdditionalInfoCard({
    super.key,
    required this.rsi,
    required this.priceChange,
    required this.volume,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('RSI', rsi.toStringAsFixed(1)),
          _buildInfoItem('24h Change', '${priceChange.toStringAsFixed(2)}%'),
          _buildInfoItem(
            'Volume',
            volume > 0 ? '\$${(volume / 1000000).toStringAsFixed(1)}M' : 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

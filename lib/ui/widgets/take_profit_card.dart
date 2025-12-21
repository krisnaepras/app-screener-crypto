import 'package:flutter/material.dart';

class TakeProfitCard extends StatelessWidget {
  final double tp1;
  final double tp2;
  final double tp3;

  const TakeProfitCard({
    super.key,
    required this.tp1,
    required this.tp2,
    required this.tp3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TAKE PROFIT TARGETS',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Scale Out Strategy',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTPRow('TP1 (40%)', tp1, 0.8),
          const Divider(height: 12),
          _buildTPRow('TP2 (40%)', tp2, 1.5),
          const Divider(height: 12),
          _buildTPRow('TP3 (20%)', tp3, 2.5),
        ],
      ),
    );
  }

  Widget _buildTPRow(String label, double price, double percent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            Text(
              '\$${price.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                '+${percent.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

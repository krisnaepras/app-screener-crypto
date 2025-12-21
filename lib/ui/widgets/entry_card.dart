import 'package:flutter/material.dart';
import '../../models/coin_data.dart';
import '../../utils/entry_calculator.dart';
import 'coin_header.dart';
import 'multi_timeframe_card.dart';
import 'entry_strategy_card.dart';
import 'price_info_row.dart';
import 'stop_loss_card.dart';
import 'take_profit_card.dart';
import 'additional_info_card.dart';

class EntryCard extends StatelessWidget {
  final CoinData coin;
  final int index;

  const EntryCard({super.key, required this.coin, required this.index});

  @override
  Widget build(BuildContext context) {
    final isLong = EntryCalculator.determineEntryType(coin) == 'LONG';
    final entry = coin.price;
    final sl = EntryCalculator.calculateSL(entry, isLong);
    final tp1 = EntryCalculator.calculateTP(entry, isLong, 0);
    final tp2 = EntryCalculator.calculateTP(entry, isLong, 1);
    final tp3 = EntryCalculator.calculateTP(entry, isLong, 2);
    final slDistance = ((entry - sl).abs() / entry * 100);
    final riskReward = ((tp3 - entry).abs() / (entry - sl).abs());
    final rsi = EntryCalculator.getRSI(coin);
    final volume = EntryCalculator.getVolume(coin);
    final entryConfirmation = EntryCalculator.getEntryConfirmation(coin);
    final entryStrategy = EntryCalculator.getEntryStrategy(coin);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CoinHeader(coin: coin, rank: index + 1, isLong: isLong),
            const Divider(height: 24),
            MultiTimeframeCard(confirmation: entryConfirmation),
            const SizedBox(height: 12),
            EntryStrategyCard(strategy: entryStrategy),
            const SizedBox(height: 12),
            PriceInfoRow(price: entry),
            const SizedBox(height: 16),
            StopLossCard(stopLoss: sl, distance: slDistance),
            const SizedBox(height: 12),
            TakeProfitCard(tp1: tp1, tp2: tp2, tp3: tp3),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Risk/Reward Ratio:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '1:${riskReward.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AdditionalInfoCard(
              rsi: rsi,
              priceChange: coin.priceChangePercent,
              volume: volume,
            ),
          ],
        ),
      ),
    );
  }
}

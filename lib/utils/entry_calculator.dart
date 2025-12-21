import '../models/coin_data.dart';

class EntryCalculator {
  static double calculateSL(double entry, bool isLong) {
    final slPercent = 0.006;
    return isLong ? entry * (1 - slPercent) : entry * (1 + slPercent);
  }

  static double calculateTP(double entry, bool isLong, int tpLevel) {
    final tpPercents = [0.008, 0.015, 0.025];
    final tpPercent = tpPercents[tpLevel];
    return isLong ? entry * (1 + tpPercent) : entry * (1 - tpPercent);
  }

  static String determineEntryType(CoinData coin) {
    final rsi = getRSI(coin);
    final priceChange = coin.priceChangePercent;

    if (rsi > 70 && priceChange > 3) {
      return 'SHORT';
    } else if (coin.status == 'TRIGGER' && priceChange > 5) {
      return 'SHORT';
    } else if (rsi > 65 && coin.fundingRate > 0.01) {
      return 'SHORT';
    } else if (priceChange < -2) {
      return 'SHORT';
    } else if (priceChange > 0 && rsi < 40) {
      return 'LONG';
    } else {
      return 'SHORT';
    }
  }

  static String getEntryConfirmation(CoinData coin) {
    final rsi = getRSI(coin);
    final priceChange = coin.priceChangePercent;

    if (coin.status == 'TRIGGER') {
      if (rsi > 70) return '✓ 1m: Overbought | 5m: Rejection zone';
      if (priceChange > 5) return '✓ 1m: Parabolic | 5m: Exhaustion';
      return '⚠ Wait for 1m pullback confirmation';
    } else if (rsi > 65) {
      return '✓ 1m: Resistance test | 5m: Bearish divergence likely';
    } else if (priceChange > 3) {
      return '⚠ 1m: Strong rally | 5m: Wait for consolidation';
    } else {
      return '⏱ Monitor 1m for entry signal';
    }
  }

  static String getEntryStrategy(CoinData coin) {
    final rsi = getRSI(coin);
    final priceChange = coin.priceChangePercent;

    if (rsi > 70 && priceChange > 5) {
      return 'Aggressive: Enter on 1m lower high | Conservative: Wait 5m confirmation';
    } else if (rsi > 65) {
      return 'Enter on 1m rejection wick | Set alert for 5m bearish candle';
    } else if (priceChange > 3) {
      return 'Wait for 1m consolidation break | Watch 5m structure';
    } else {
      return 'Scale in: 50% on 1m signal, 50% on 5m confirmation';
    }
  }

  static double getRSI(CoinData coin) {
    if (coin.features?.rsi != null) {
      return coin.features!.rsi!;
    }
    final change = coin.priceChangePercent;
    if (change > 5) return 70;
    if (change < -5) return 30;
    return 50 + (change * 2);
  }

  static double getVolume(CoinData coin) {
    return 0;
  }
}

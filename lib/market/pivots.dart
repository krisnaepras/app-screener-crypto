class Pivot {
  final int index;
  final double price;

  Pivot(this.index, this.price);
}

List<Pivot> findPivotLows(List<double> lows, {int leftBars = 2, int rightBars = 2}) {
  final List<Pivot> pivots = [];

  for (int i = leftBars; i < lows.length - rightBars; i++) {
    final double currentLow = lows[i];
    bool isPivot = true;

    // Check left
    for (int j = 1; j <= leftBars; j++) {
      if (lows[i - j] <= currentLow) {
        isPivot = false;
        break;
      }
    }

    // Check right
    if (isPivot) {
      for (int j = 1; j <= rightBars; j++) {
        if (lows[i + j] <= currentLow) {
           isPivot = false;
           break;
        }
      }
    }

    if (isPivot) {
      pivots.add(Pivot(i, currentLow));
    }
  }

  return pivots;
}

Pivot? getNearestSupport(List<Pivot> pivots, int currentIndex) {
  for (int i = pivots.length - 1; i >= 0; i--) {
    if (pivots[i].index < currentIndex) {
      return pivots[i];
    }
  }
  return null;
}

bool isBreakdown(double close, double support, double atr, {double thresholdFactor = 0.1}) {
  return close < support - (thresholdFactor * atr);
}

bool isInRetestZone(double high, double low, double support, double atr, {double rangeFactor = 0.2}) {
  final double upperZone = support + rangeFactor * atr;
  final double lowerZone = support - rangeFactor * atr;

  return (low <= upperZone && high >= lowerZone);
}

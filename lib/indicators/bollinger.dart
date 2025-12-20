import 'dart:math' as math;

class BollingerBands {
  final List<double?> upper;
  final List<double?> middle;
  final List<double?> lower;

  BollingerBands(this.upper, this.middle, this.lower);
}

BollingerBands calculateBollingerBands(List<double> closes, int period, double multiplier) {
  final List<double?> upper = List.filled(closes.length, null);
  final List<double?> middle = List.filled(closes.length, null);
  final List<double?> lower = List.filled(closes.length, null);

  if (closes.length < period) return BollingerBands(upper, middle, lower);

  for (int i = period - 1; i < closes.length; i++) {
    // Simple MA
    double sum = 0;
    for (int j = 0; j < period; j++) {
      sum += closes[i - j];
    }
    double ma = sum / period;
    middle[i] = ma;

    // Standard Deviation
    double sumSqDiff = 0;
    for (int j = 0; j < period; j++) {
      sumSqDiff += (closes[i - j] - ma) * (closes[i - j] - ma);
    }
    double stdDev = 0;
    if (period > 1) {
        stdDev = math.sqrt(sumSqDiff / period);
    }
    
    upper[i] = ma + (multiplier * stdDev);
    lower[i] = ma - (multiplier * stdDev);
  }

  return BollingerBands(upper, middle, lower);
}


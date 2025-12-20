List<double?> calculateATR(List<double> highs, List<double> lows, List<double> closes, int period) {
  final List<double?> atr = List.filled(closes.length, null);

  if (closes.length < period + 1) return atr;

  List<double> trs = [];
  // TR1 = High - Low (first bar) is usually undefined or just H-L but need prev close for true TR?
  // Wilder starts with H-L for the first period?
  // Standard: TR[i] = max(H[i]-L[i], abs(H[i]-C[i-1]), abs(L[i]-C[i-1]))
  
  // We can calculate TR starting from index 1.
  for (int i = 0; i < closes.length; i++) {
    if (i == 0) {
      trs.add(highs[i] - lows[i]); 
    } else {
      double hl = highs[i] - lows[i];
      double hc = (highs[i] - closes[i - 1]).abs();
      double lc = (lows[i] - closes[i - 1]).abs();
      trs.add([hl, hc, lc].reduce((a, b) => a > b ? a : b));
    }
  }

  // First ATR = Simple Average of TRs
  double sumTR = 0;
  for (int i = 0; i < period; i++) {
    sumTR += trs[i];
  }
  atr[period - 1] = sumTR / period;

  // Smoothing: ATR[i] = (ATR[i-1] * (n-1) + TR[i]) / n
  for (int i = period; i < closes.length; i++) {
    atr[i] = (atr[i - 1]! * (period - 1) + trs[i]) / period;
  }

  return atr;
}

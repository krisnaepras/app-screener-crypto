List<double?> calculateRSI(List<double> closes, int period) {
  final List<double?> rsi = List.filled(closes.length, null);

  if (closes.length < period + 1) return rsi;

  List<double> gains = [];
  List<double> losses = [];

  for (int i = 1; i < closes.length; i++) {
    double change = closes[i] - closes[i - 1];
    gains.add(change > 0 ? change : 0);
    losses.add(change < 0 ? -change : 0);
  }

  // First average gain/loss
  double avgGain = gains.sublist(0, period).reduce((a, b) => a + b) / period;
  double avgLoss = losses.sublist(0, period).reduce((a, b) => a + b) / period;

  // Smoothing
  for (int i = period; i < closes.length; i++) {
    // Note: gains index i-1 corresponds to close index i vs i-1
    rsi[i] = 100 - (100 / (1 + (avgLoss == 0 ? 100 : avgGain / avgLoss)));

    // Next step
    if (i < closes.length - 1) { // bounds check redundant really but safe
       // We need the gain/loss for the NEXT iteration.
       // The loop handles calculating RSI[i].
       // For the next iteration i+1:
       // The current gain/loss being processed was based on close[i] - close[i-1].
       // We need to update avgGain/Loss for the *next* calculation.
    }
  }

  // Re-implementing specifically to match standard Wilder's RSI Loop
  // Reset
  avgGain = gains.sublist(0, period).reduce((a, b) => a + b) / period;
  avgLoss = losses.sublist(0, period).reduce((a, b) => a + b) / period;
  
  rsi[period] = 100 - (100 / (1 + (avgLoss == 0 ? 100 : avgGain / avgLoss)));

  for (int i = period + 1; i < closes.length; i++) {
    double currentGain = gains[i-1];
    double currentLoss = losses[i-1];

    avgGain = ((avgGain * (period - 1)) + currentGain) / period;
    avgLoss = ((avgLoss * (period - 1)) + currentLoss) / period;

    rsi[i] = 100 - (100 / (1 + (avgLoss == 0 ? 100 : avgGain / avgLoss)));
  }

  return rsi;
}

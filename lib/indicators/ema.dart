import 'dart:math';

List<double?> calculateEMA(List<double> data, int period) {
  final List<double?> ema = List.filled(data.length, null);
  final k = 2 / (period + 1);

  if (data.length < period) return ema;

  // Simple MA for the first EMA
  double sum = 0;
  for (int i = 0; i < period; i++) {
    sum += data[i];
  }
  ema[period - 1] = sum / period;

  for (int i = period; i < data.length; i++) {
    ema[i] = (data[i] * k) + (ema[i - 1]! * (1 - k));
  }

  return ema;
}

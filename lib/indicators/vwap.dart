List<double?> calculateVWAP(List<List<dynamic>> klines) {
  // klines: [time, open, high, low, close, volume, ...]
  // We need Typical Price * Volume
  
  final List<double?> vwap = List.filled(klines.length, null);
  
  double cumulativeTPV = 0;
  double cumulativeVol = 0;
  
  // VWAP is typically reset daily. Assuming this is intraday data or a rolling window.
  // The TS code likely does a cumulative over the visible range.
  
  for (int i = 0; i < klines.length; i++) {
    double high = double.parse(klines[i][2].toString());
    double low = double.parse(klines[i][3].toString());
    double close = double.parse(klines[i][4].toString());
    double volume = double.parse(klines[i][5].toString());
    
    double typicalPrice = (high + low + close) / 3;
    
    cumulativeTPV += (typicalPrice * volume);
    cumulativeVol += volume;
    
    if (cumulativeVol > 0) {
      vwap[i] = cumulativeTPV / cumulativeVol;
    }
  }
  
  return vwap;
}

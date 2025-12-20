import '../indicators/bollinger.dart';
import '../market/pivots.dart';
import '../services/binance_service.dart'; // Define later

class MarketFeatures {
  final double pctChange24h;
  final double overExtEma;
  final double overExtVwap;
  final bool isAboveUpperBand;
  final double candleRangeRatio;
  final double rsi;
  final bool isRsiBearishDiv;
  final double rejectionWickRatio;
  final double fundingRate;
  final double openInterestDelta;
  final double? nearestSupport;
  final double? distToSupportATR;
  final bool isBreakdown;
  final bool isRetest;
  final bool isRetestFail;

  MarketFeatures({
    required this.pctChange24h,
    required this.overExtEma,
    required this.overExtVwap,
    required this.isAboveUpperBand,
    required this.candleRangeRatio,
    required this.rsi,
    required this.isRsiBearishDiv,
    required this.rejectionWickRatio,
    required this.fundingRate,
    required this.openInterestDelta,
    this.nearestSupport,
    this.distToSupportATR,
    required this.isBreakdown,
    required this.isRetest,
    required this.isRetestFail,
  });

  Map<String, dynamic> toJson() => {
    'pctChange24h': pctChange24h,
    'overExtEma': overExtEma,
    'overExtVwap': overExtVwap,
    'isAboveUpperBand': isAboveUpperBand,
    'candleRangeRatio': candleRangeRatio,
    'rsi': rsi,
    'isRsiBearishDiv': isRsiBearishDiv,
    'rejectionWickRatio': rejectionWickRatio,
    'fundingRate': fundingRate,
    'openInterestDelta': openInterestDelta,
    'nearestSupport': nearestSupport,
    'distToSupportATR': distToSupportATR,
    'isBreakdown': isBreakdown,
    'isRetest': isRetest,
    'isRetestFail': isRetestFail,
  };

  factory MarketFeatures.fromJson(Map<String, dynamic> json) => MarketFeatures(
    pctChange24h: (json['pctChange24h'] ?? 0).toDouble(),
    overExtEma: (json['overExtEma'] ?? 0).toDouble(),
    overExtVwap: (json['overExtVwap'] ?? 0).toDouble(),
    isAboveUpperBand: json['isAboveUpperBand'] ?? false,
    candleRangeRatio: (json['candleRangeRatio'] ?? 0).toDouble(),
    rsi: (json['rsi'] ?? 50).toDouble(),
    isRsiBearishDiv: json['isRsiBearishDiv'] ?? false,
    rejectionWickRatio: (json['rejectionWickRatio'] ?? 0).toDouble(),
    fundingRate: (json['fundingRate'] ?? 0).toDouble(),
    openInterestDelta: (json['openInterestDelta'] ?? 0).toDouble(),
    nearestSupport: json['nearestSupport']?.toDouble(),
    distToSupportATR: json['distToSupportATR']?.toDouble(),
    isBreakdown: json['isBreakdown'] ?? false,
    isRetest: json['isRetest'] ?? false,
    isRetestFail: json['isRetestFail'] ?? false,
  );
}

MarketFeatures extractFeatures(
  List<double> prices, // Close
  List<double> highs,
  List<double> lows,
  Ticker24h ticker,
  List<double?> ema50,
  List<double?> vwap,
  List<double?> rsi,
  BollingerBands bb,
  List<double?> atr,
  List<Pivot> pivots, {
  double fundingRate = 0,
  double oiDelta = 0,
}) {
  final int lastIdx = prices.length - 1;
  final double currentClose = prices[lastIdx];
  final double currentHigh = highs[lastIdx];
  final double currentLow = lows[lastIdx];

  // Indicators
  final double? currentEma = ema50[lastIdx];
  final double? currentVwap = vwap[lastIdx];
  final double currentRsi = rsi[lastIdx] ?? 50;
  final double currentAtr = atr[lastIdx] ?? 0;
  final double? currentUpperBand = bb.upper[lastIdx];

  // Overextension
  final double overExtEma = currentEma != null
      ? (currentClose - currentEma) / currentEma
      : 0;
  final double overExtVwap = currentVwap != null
      ? (currentClose - currentVwap) / currentVwap
      : 0;
  final bool isAboveUpperBand = currentUpperBand != null
      ? currentClose > currentUpperBand
      : false;

  // Placeholder
  const double rejectionWickRatio = 0;

  // Structure
  final Pivot? nearestSupPivot = getNearestSupport(pivots, lastIdx);
  final double? supportPrice = nearestSupPivot?.price;

  bool isBrk = false;
  bool isRetestZone = false;

  if (supportPrice != null && currentAtr > 0) {
    isBrk = isBreakdown(currentClose, supportPrice, currentAtr);
    isRetestZone = isInRetestZone(
      currentHigh,
      currentLow,
      supportPrice,
      currentAtr,
    );
  }

  final double? distToSupportATR = (supportPrice != null && currentAtr > 0)
      ? (currentClose - supportPrice) / currentAtr
      : null;

  return MarketFeatures(
    pctChange24h: double.tryParse(ticker.priceChangePercent) ?? 0,
    overExtEma: overExtEma,
    overExtVwap: overExtVwap,
    isAboveUpperBand: isAboveUpperBand,
    candleRangeRatio: 0,
    rsi: currentRsi,
    isRsiBearishDiv: false,
    rejectionWickRatio: rejectionWickRatio,
    fundingRate: fundingRate,
    openInterestDelta: oiDelta,
    nearestSupport: supportPrice,
    distToSupportATR: distToSupportATR,
    isBreakdown: isBrk,
    isRetest: isRetestZone,
    isRetestFail: false,
  );
}

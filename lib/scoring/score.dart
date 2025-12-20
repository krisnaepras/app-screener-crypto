import 'features.dart';

class ScoreComponents {
  final double overextension;
  final double crowding;
  final double exhaustion;
  final double structure;

  ScoreComponents({
    required this.overextension,
    required this.crowding,
    required this.exhaustion,
    required this.structure,
  });
}

class ScoreResult {
  final double totalScore;
  final ScoreComponents components;

  ScoreResult(this.totalScore, this.components);
}

ScoreResult calculateScore(MarketFeatures features) {
  // Weights (Normal)
  // Overextension: 0-30
  // Crowding: 0-20
  // Exhaustion: 0-25
  // Structure: 0-25

  double sOver = 0;
  if (features.pctChange24h >= 40) {
    sOver += 15;
  } else if (features.pctChange24h >= 20) {
    sOver += 10;
  }

  // EMA Overext
  if (features.overExtEma >= 0.05) {
     sOver += 10;
  } else if (features.overExtEma >= 0.03) {
     sOver += 5;
  }

  // VWAP Overext
  if (features.overExtVwap >= 0.03) sOver += 5;

  sOver = sOver > 30 ? 30 : sOver;

  double sCrowd = 0;
  // Funding
  if (features.fundingRate > 0.0001) sCrowd += 5;
  if (features.fundingRate > 0.0005) sCrowd += 10;
  // OI delta
  if (features.openInterestDelta > 0) sCrowd += 5;

  sCrowd = sCrowd > 20 ? 20 : sCrowd;

  double sExhaust = 0;
  if (features.rsi > 70) {
    sExhaust += 15;
  } else if (features.rsi > 60) {
    sExhaust += 5;
  }

  if (features.isAboveUpperBand) sExhaust += 5;

  sExhaust = sExhaust > 25 ? 25 : sExhaust;

  double sStruct = 0;
  if (features.isBreakdown) sStruct += 15;
  if (features.isRetest) sStruct += 10;

  sStruct = sStruct > 25 ? 25 : sStruct;

  return ScoreResult(
    sOver + sCrowd + sExhaust + sStruct,
    ScoreComponents(
      overextension: sOver,
      crowding: sCrowd,
      exhaustion: sExhaust,
      structure: sStruct,
    ),
  );
}

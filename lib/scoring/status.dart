import 'score.dart';
import 'features.dart';

String determineStatus(ScoreResult score, MarketFeatures features) {
  final double s = score.totalScore;

  if (s >= 75) {
    if (features.isBreakdown || features.isRetestFail) {
      return 'TRIGGER';
    }
    return 'SETUP';
  }

  if (s >= 55) {
    return 'SETUP';
  }

  if (s >= 35) {
    return 'WATCH';
  }

  return 'AVOID';
}

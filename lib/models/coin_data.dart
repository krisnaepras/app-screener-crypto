import '../scoring/features.dart';

class TimeframeScore {
  final String tf;
  final double score;
  final double rsi;

  TimeframeScore({required this.tf, required this.score, this.rsi = 50});

  factory TimeframeScore.fromJson(Map<String, dynamic> json) {
    return TimeframeScore(
      tf: json['tf'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      rsi: (json['rsi'] ?? 50).toDouble(),
    );
  }
}

class TimeframeFeatures {
  final String tf;
  final double rsi;
  final double overExtEma;
  final bool isAboveUpperBB;
  final bool isBreakdown;

  TimeframeFeatures({
    required this.tf,
    required this.rsi,
    required this.overExtEma,
    required this.isAboveUpperBB,
    required this.isBreakdown,
  });

  factory TimeframeFeatures.fromJson(Map<String, dynamic> json) {
    return TimeframeFeatures(
      tf: json['tf'] ?? '',
      rsi: (json['rsi'] ?? 50).toDouble(),
      overExtEma: (json['overExtEma'] ?? 0).toDouble(),
      isAboveUpperBB: json['isAboveUpperBB'] ?? false,
      isBreakdown: json['isBreakdown'] ?? false,
    );
  }
}

class CoinData {
  final String symbol;
  final double price;
  final double score;
  final String status;
  final String? triggerTf;
  final int confluenceCount;
  final List<TimeframeScore> tfScores;
  final List<TimeframeFeatures> tfFeatures;
  final double priceChangePercent;
  final double fundingRate;
  final double basisSpread;
  final MarketFeatures? features;
  // Intraday fields (SHORT)
  final String intradayStatus;
  final double intradayScore;
  final List<TimeframeScore> intradayTfScores;
  final MarketFeatures? intradayFeatures;
  // Pullback Entry fields (Buy the Dip)
  final String pullbackStatus;
  final double pullbackScore;
  final List<TimeframeScore> pullbackTfScores;
  final MarketFeatures? pullbackFeatures;
  // Breakout Hunter fields
  final String breakoutStatus;
  final String breakoutDirection;
  final double breakoutScore;
  final List<TimeframeScore> breakoutTfScores;
  final MarketFeatures? breakoutFeatures;
  // Follow Trend fields
  final String followTrendStatus;
  final String followTrendDirection;
  final double followTrendScore;
  final List<TimeframeScore> followTrendTfScores;
  final MarketFeatures? followTrendFeatures;

  CoinData({
    required this.symbol,
    required this.price,
    required this.score,
    required this.status,
    this.triggerTf,
    this.confluenceCount = 0,
    this.tfScores = const [],
    this.tfFeatures = const [],
    required this.priceChangePercent,
    required this.fundingRate,
    this.basisSpread = 0,
    this.features,
    this.intradayStatus = '',
    this.intradayScore = 0,
    this.intradayTfScores = const [],
    this.intradayFeatures,
    this.pullbackStatus = '',
    this.pullbackScore = 0,
    this.pullbackTfScores = const [],
    this.pullbackFeatures,
    this.breakoutStatus = '',
    this.breakoutDirection = '',
    this.breakoutScore = 0,
    this.breakoutTfScores = const [],
    this.breakoutFeatures,
    this.followTrendStatus = '',
    this.followTrendDirection = '',
    this.followTrendScore = 0,
    this.followTrendTfScores = const [],
    this.followTrendFeatures,
  });

  factory CoinData.fromJson(Map<String, dynamic> json) {
    List<TimeframeScore> parsedTfScores = [];
    if (json['tfScores'] != null) {
      parsedTfScores = (json['tfScores'] as List)
          .map((e) => TimeframeScore.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    List<TimeframeFeatures> parsedTfFeatures = [];
    if (json['tfFeatures'] != null) {
      parsedTfFeatures = (json['tfFeatures'] as List)
          .map((e) => TimeframeFeatures.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    List<TimeframeScore> parsedIntradayTfScores = [];
    if (json['intradayTfScores'] != null) {
      parsedIntradayTfScores = (json['intradayTfScores'] as List)
          .map((e) => TimeframeScore.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    List<TimeframeScore> parsedPullbackTfScores = [];
    if (json['pullbackTfScores'] != null) {
      parsedPullbackTfScores = (json['pullbackTfScores'] as List)
          .map((e) => TimeframeScore.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    List<TimeframeScore> parsedBreakoutTfScores = [];
    if (json['breakoutTfScores'] != null) {
      parsedBreakoutTfScores = (json['breakoutTfScores'] as List)
          .map((e) => TimeframeScore.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    List<TimeframeScore> parsedFollowTrendTfScores = [];
    if (json['followTrendTfScores'] != null) {
      parsedFollowTrendTfScores = (json['followTrendTfScores'] as List)
          .map((e) => TimeframeScore.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return CoinData(
      symbol: json['symbol'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      score: (json['score'] ?? 0).toDouble(),
      status: json['status'] ?? 'AVOID',
      triggerTf: json['triggerTf'],
      confluenceCount: (json['confluenceCount'] ?? 0).toInt(),
      tfScores: parsedTfScores,
      tfFeatures: parsedTfFeatures,
      priceChangePercent: (json['priceChangePercent'] ?? 0).toDouble(),
      fundingRate: (json['fundingRate'] ?? 0).toDouble(),
      basisSpread: (json['basisSpread'] ?? 0).toDouble(),
      features: json['features'] != null
          ? MarketFeatures.fromJson(Map<String, dynamic>.from(json['features']))
          : null,
      intradayStatus: json['intradayStatus'] ?? '',
      intradayScore: (json['intradayScore'] ?? 0).toDouble(),
      intradayTfScores: parsedIntradayTfScores,
      intradayFeatures: json['intradayFeatures'] != null
          ? MarketFeatures.fromJson(
              Map<String, dynamic>.from(json['intradayFeatures']),
            )
          : null,
      pullbackStatus: json['pullbackStatus'] ?? '',
      pullbackScore: (json['pullbackScore'] ?? 0).toDouble(),
      pullbackTfScores: parsedPullbackTfScores,
      pullbackFeatures: json['pullbackFeatures'] != null
          ? MarketFeatures.fromJson(
              Map<String, dynamic>.from(json['pullbackFeatures']),
            )
          : null,
      breakoutStatus: json['breakoutStatus'] ?? '',
      breakoutDirection: json['breakoutDirection'] ?? '',
      breakoutScore: (json['breakoutScore'] ?? 0).toDouble(),
      breakoutTfScores: parsedBreakoutTfScores,
      breakoutFeatures: json['breakoutFeatures'] != null
          ? MarketFeatures.fromJson(
              Map<String, dynamic>.from(json['breakoutFeatures']),
            )
          : null,
      followTrendStatus: json['followTrendStatus'] ?? '',
      followTrendDirection: json['followTrendDirection'] ?? '',
      followTrendScore: (json['followTrendScore'] ?? 0).toDouble(),
      followTrendTfScores: parsedFollowTrendTfScores,
      followTrendFeatures: json['followTrendFeatures'] != null
          ? MarketFeatures.fromJson(
              Map<String, dynamic>.from(json['followTrendFeatures']),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'price': price,
    'score': score,
    'status': status,
    'triggerTf': triggerTf,
    'confluenceCount': confluenceCount,
    'tfScores': tfScores
        .map((e) => {'tf': e.tf, 'score': e.score, 'rsi': e.rsi})
        .toList(),
    'priceChangePercent': priceChangePercent,
    'fundingRate': fundingRate,
    'basisSpread': basisSpread,
    'features': features?.toJson(),
    'intradayStatus': intradayStatus,
    'intradayScore': intradayScore,
    'intradayTfScores': intradayTfScores
        .map((e) => {'tf': e.tf, 'score': e.score, 'rsi': e.rsi})
        .toList(),
    'intradayFeatures': intradayFeatures?.toJson(),
    'pullbackStatus': pullbackStatus,
    'pullbackScore': pullbackScore,
    'pullbackTfScores': pullbackTfScores
        .map((e) => {'tf': e.tf, 'score': e.score, 'rsi': e.rsi})
        .toList(),
    'pullbackFeatures': pullbackFeatures?.toJson(),
    'breakoutStatus': breakoutStatus,
    'breakoutDirection': breakoutDirection,
    'breakoutScore': breakoutScore,
    'breakoutTfScores': breakoutTfScores
        .map((e) => {'tf': e.tf, 'score': e.score, 'rsi': e.rsi})
        .toList(),
    'breakoutFeatures': breakoutFeatures?.toJson(),
    'followTrendStatus': followTrendStatus,
    'followTrendDirection': followTrendDirection,
    'followTrendScore': followTrendScore,
    'followTrendTfScores': followTrendTfScores
        .map((e) => {'tf': e.tf, 'score': e.score, 'rsi': e.rsi})
        .toList(),
    'followTrendFeatures': followTrendFeatures?.toJson(),
  };
}

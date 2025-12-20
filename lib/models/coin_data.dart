import '../scoring/features.dart';

class CoinData {
  final String symbol;
  final double price;
  final double score;
  final String status;
  final double priceChangePercent;
  final double fundingRate;
  final double basisSpread;
  final MarketFeatures? features;

  CoinData({
    required this.symbol,
    required this.price,
    required this.score,
    required this.status,
    required this.priceChangePercent,
    required this.fundingRate,
    this.basisSpread = 0,
    this.features,
  });

  factory CoinData.fromJson(Map<String, dynamic> json) {
    return CoinData(
      symbol: json['symbol'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      score: (json['score'] ?? 0).toDouble(),
      status: json['status'] ?? 'AVOID',
      priceChangePercent: (json['priceChangePercent'] ?? 0).toDouble(),
      fundingRate: (json['fundingRate'] ?? 0).toDouble(),
      basisSpread: (json['basisSpread'] ?? 0).toDouble(),
      features: json['features'] != null
          ? MarketFeatures.fromJson(Map<String, dynamic>.from(json['features']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'price': price,
    'score': score,
    'status': status,
    'priceChangePercent': priceChangePercent,
    'fundingRate': fundingRate,
    'basisSpread': basisSpread,
    'features': features?.toJson(),
  };
}

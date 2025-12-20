class CoinData {
  final String symbol;
  final double price;
  final double score;
  final String status;
  final double priceChangePercent;
  final double fundingRate;

  CoinData({
    required this.symbol,
    required this.price,
    required this.score,
    required this.status,
    required this.priceChangePercent,
    required this.fundingRate,
  });

  factory CoinData.fromJson(Map<String, dynamic> json) {
    return CoinData(
      symbol: json['symbol'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      score: (json['score'] ?? 0).toDouble(),
      status: json['status'] ?? 'AVOID',
      priceChangePercent: (json['priceChangePercent'] ?? 0).toDouble(),
      fundingRate: (json['fundingRate'] ?? 0).toDouble(),
    );
  }
}

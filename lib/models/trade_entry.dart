class TradeEntry {
  final String id;
  final String symbol;
  final bool isLong;
  final double entryPrice;
  final double stopLoss;
  final double takeProfit1;
  final double takeProfit2;
  final double takeProfit3;
  final DateTime entryTime;
  final String
  status; // 'active', 'tp1_hit', 'tp2_hit', 'tp3_hit', 'stopped', 'closed'
  final double? exitPrice;
  final DateTime? exitTime;
  final double? profitLoss;
  final String entryReason;

  TradeEntry({
    required this.id,
    required this.symbol,
    required this.isLong,
    required this.entryPrice,
    required this.stopLoss,
    required this.takeProfit1,
    required this.takeProfit2,
    required this.takeProfit3,
    required this.entryTime,
    required this.status,
    this.exitPrice,
    this.exitTime,
    this.profitLoss,
    this.entryReason = '',
  });

  Map<String, dynamic> toJson() {
    // Convert to UTC and use RFC3339 format (compatible with Go's time.Time)
    final entryTimeUtc = entryTime.toUtc().toIso8601String();
    final exitTimeUtc = exitTime?.toUtc().toIso8601String();

    return {
      'id': id,
      'symbol': symbol,
      'isLong': isLong,
      'entryPrice': entryPrice,
      'stopLoss': stopLoss,
      'takeProfit1': takeProfit1,
      'takeProfit2': takeProfit2,
      'takeProfit3': takeProfit3,
      'entryTime': entryTimeUtc,
      'status': status,
      'exitPrice': exitPrice,
      'exitTime': exitTimeUtc,
      'profitLoss': profitLoss,
      'entryReason': entryReason,
    };
  }

  factory TradeEntry.fromJson(Map<String, dynamic> json) => TradeEntry(
    id: json['id'],
    symbol: json['symbol'],
    isLong: json['isLong'],
    entryPrice: json['entryPrice'],
    stopLoss: json['stopLoss'],
    takeProfit1: json['takeProfit1'],
    takeProfit2: json['takeProfit2'],
    takeProfit3: json['takeProfit3'],
    entryTime: DateTime.parse(json['entryTime']),
    status: json['status'],
    exitPrice: json['exitPrice'],
    exitTime: json['exitTime'] != null
        ? DateTime.parse(json['exitTime'])
        : null,
    profitLoss: json['profitLoss'],
    entryReason: json['entryReason'] ?? '',
  );

  TradeEntry copyWith({
    String? status,
    double? exitPrice,
    DateTime? exitTime,
    double? profitLoss,
  }) {
    return TradeEntry(
      id: id,
      symbol: symbol,
      isLong: isLong,
      entryPrice: entryPrice,
      stopLoss: stopLoss,
      takeProfit1: takeProfit1,
      takeProfit2: takeProfit2,
      takeProfit3: takeProfit3,
      entryTime: entryTime,
      status: status ?? this.status,
      exitPrice: exitPrice ?? this.exitPrice,
      exitTime: exitTime ?? this.exitTime,
      profitLoss: profitLoss ?? this.profitLoss,
      entryReason: entryReason,
    );
  }

  double get currentProfitLossPercent {
    if (exitPrice == null) return 0;
    final diff = isLong ? exitPrice! - entryPrice : entryPrice - exitPrice!;
    return (diff / entryPrice) * 100;
  }

  bool get isActive => status == 'active' || status.contains('tp');
}

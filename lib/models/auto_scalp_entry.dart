class AutoScalpEntry {
  final String id;
  final String symbol;
  final double entryPrice;
  final double stopLoss;
  final double? exitPrice;
  final DateTime entryTime;
  final DateTime? exitTime;
  final String exitReason;
  final double? profitLoss;
  final double? profitLossPct;
  final String status;
  final double highestPrice;
  final double trailingStopPct;
  final int durationSeconds;

  AutoScalpEntry({
    required this.id,
    required this.symbol,
    required this.entryPrice,
    required this.stopLoss,
    this.exitPrice,
    required this.entryTime,
    this.exitTime,
    required this.exitReason,
    this.profitLoss,
    this.profitLossPct,
    required this.status,
    required this.highestPrice,
    required this.trailingStopPct,
    required this.durationSeconds,
  });

  factory AutoScalpEntry.fromJson(Map<String, dynamic> json) {
    return AutoScalpEntry(
      id: json['id'].toString(),
      symbol: json['symbol'] ?? '',
      entryPrice: (json['entryPrice'] ?? 0).toDouble(),
      stopLoss: (json['stopLoss'] ?? 0).toDouble(),
      exitPrice: json['exitPrice']?.toDouble(),
      entryTime: json['entryTime'] != null
          ? DateTime.parse(json['entryTime'])
          : DateTime.now(),
      exitTime: json['exitTime'] != null
          ? DateTime.parse(json['exitTime'])
          : null,
      exitReason: json['exitReason'] ?? '',
      profitLoss: json['profitLoss']?.toDouble(),
      profitLossPct: json['profitLossPct']?.toDouble(),
      status: json['status'] ?? 'UNKNOWN',
      highestPrice: (json['highestPrice'] ?? 0).toDouble(),
      trailingStopPct: (json['trailingStopPct'] ?? 0).toDouble(),
      durationSeconds: json['durationSeconds'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'entryPrice': entryPrice,
      'stopLoss': stopLoss,
      'exitPrice': exitPrice,
      'entryTime': entryTime.toUtc().toIso8601String(),
      'exitTime': exitTime?.toUtc().toIso8601String(),
      'exitReason': exitReason,
      'profitLoss': profitLoss,
      'profitLossPct': profitLossPct,
      'status': status,
      'highestPrice': highestPrice,
      'trailingStopPct': trailingStopPct,
      'durationSeconds': durationSeconds,
    };
  }
}

class AutoScalpSettings {
  bool enabled;
  int maxConcurrentTrades;
  double minEntryScore;
  double stopLossPercent;
  double minProfitPercent;
  double trailingStopPercent;
  int maxPositionTime;

  AutoScalpSettings({
    required this.enabled,
    required this.maxConcurrentTrades,
    required this.minEntryScore,
    required this.stopLossPercent,
    required this.minProfitPercent,
    required this.trailingStopPercent,
    required this.maxPositionTime,
  });

  factory AutoScalpSettings.fromJson(Map<String, dynamic> json) {
    return AutoScalpSettings(
      enabled: json['enabled'] ?? false,
      maxConcurrentTrades: json['maxConcurrentTrades'] ?? 3,
      minEntryScore: (json['minEntryScore'] ?? 75).toDouble(),
      stopLossPercent: (json['stopLossPercent'] ?? 0.4).toDouble(),
      minProfitPercent: (json['minProfitPercent'] ?? 0.3).toDouble(),
      trailingStopPercent: (json['trailingStopPercent'] ?? 0.15).toDouble(),
      maxPositionTime: json['maxPositionTime'] ?? 1800,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'maxConcurrentTrades': maxConcurrentTrades,
      'minEntryScore': minEntryScore,
      'stopLossPercent': stopLossPercent,
      'minProfitPercent': minProfitPercent,
      'trailingStopPercent': trailingStopPercent,
      'maxPositionTime': maxPositionTime,
    };
  }
}

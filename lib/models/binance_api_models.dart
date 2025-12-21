class BinanceAPICredentials {
  final String userId;
  final String apiKey;
  final String secretKey;
  final bool isTestnet;
  final bool isEnabled;
  final List<String> permissions;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastTested;

  BinanceAPICredentials({
    required this.userId,
    required this.apiKey,
    required this.secretKey,
    this.isTestnet = false,
    this.isEnabled = true,
    this.permissions = const [],
    this.createdAt,
    this.updatedAt,
    this.lastTested,
  });

  factory BinanceAPICredentials.fromJson(Map<String, dynamic> json) {
    return BinanceAPICredentials(
      userId: json['userId'] ?? '',
      apiKey: json['apiKey'] ?? '',
      secretKey: json['secretKey'] ?? '',
      isTestnet: json['isTestnet'] ?? false,
      isEnabled: json['isEnabled'] ?? true,
      permissions: (json['permissions'] as List?)?.cast<String>() ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      lastTested: json['lastTested'] != null
          ? DateTime.parse(json['lastTested'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'apiKey': apiKey,
      'secretKey': secretKey,
      'isTestnet': isTestnet,
      'isEnabled': isEnabled,
      'permissions': permissions,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (lastTested != null) 'lastTested': lastTested!.toIso8601String(),
    };
  }
}

class BinanceAccountInfo {
  final double totalBalance;
  final double availableBalance;
  final double usdtBalance;
  final double marginLevel;
  final int openOrdersCount;
  final int positionsCount;
  final double totalUnrealizedPL;
  final List<BinanceAsset> assets;
  final List<BinancePosition> positions;

  BinanceAccountInfo({
    required this.totalBalance,
    required this.availableBalance,
    required this.usdtBalance,
    this.marginLevel = 0,
    required this.openOrdersCount,
    required this.positionsCount,
    this.totalUnrealizedPL = 0,
    this.assets = const [],
    this.positions = const [],
  });

  factory BinanceAccountInfo.fromJson(Map<String, dynamic> json) {
    return BinanceAccountInfo(
      totalBalance: (json['totalBalance'] ?? 0).toDouble(),
      availableBalance: (json['availableBalance'] ?? 0).toDouble(),
      usdtBalance: (json['usdtBalance'] ?? 0).toDouble(),
      marginLevel: (json['marginLevel'] ?? 0).toDouble(),
      openOrdersCount: json['openOrdersCount'] ?? 0,
      positionsCount: json['positionsCount'] ?? 0,
      totalUnrealizedPL: (json['totalUnrealizedPL'] ?? 0).toDouble(),
      assets:
          (json['assets'] as List?)
              ?.map((e) => BinanceAsset.fromJson(e))
              .toList() ??
          [],
      positions:
          (json['positions'] as List?)
              ?.map((e) => BinancePosition.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class BinanceAsset {
  final String asset;
  final double balance;
  final double availableBalance;
  final double usdValue;

  BinanceAsset({
    required this.asset,
    required this.balance,
    required this.availableBalance,
    required this.usdValue,
  });

  factory BinanceAsset.fromJson(Map<String, dynamic> json) {
    return BinanceAsset(
      asset: json['asset'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      availableBalance: (json['availableBalance'] ?? 0).toDouble(),
      usdValue: (json['usdValue'] ?? 0).toDouble(),
    );
  }
}

class BinancePosition {
  final String symbol;
  final String positionSide;
  final double positionAmount;
  final double entryPrice;
  final double markPrice;
  final double unrealizedProfit;
  final int leverage;

  BinancePosition({
    required this.symbol,
    required this.positionSide,
    required this.positionAmount,
    required this.entryPrice,
    required this.markPrice,
    required this.unrealizedProfit,
    required this.leverage,
  });

  factory BinancePosition.fromJson(Map<String, dynamic> json) {
    return BinancePosition(
      symbol: json['symbol'] ?? '',
      positionSide: json['positionSide'] ?? '',
      positionAmount: (json['positionAmount'] ?? 0).toDouble(),
      entryPrice: (json['entryPrice'] ?? 0).toDouble(),
      markPrice: (json['markPrice'] ?? 0).toDouble(),
      unrealizedProfit: (json['unrealizedProfit'] ?? 0).toDouble(),
      leverage: json['leverage'] ?? 1,
    );
  }
}

class BinanceTradingConfig {
  final String userId;
  double tradeAmountUsdt;
  int leverage;
  String orderType;
  double maxSlippagePercent;
  double maxDailyLossUsdt;
  int maxDailyTrades;
  bool enableRealTrading;
  bool useStopLoss;
  bool useTakeProfit;
  double defaultStopLossPct;
  double defaultTakeProfitPct;

  BinanceTradingConfig({
    required this.userId,
    this.tradeAmountUsdt = 10.0,
    this.leverage = 1,
    this.orderType = 'MARKET',
    this.maxSlippagePercent = 0.5,
    this.maxDailyLossUsdt = 100.0,
    this.maxDailyTrades = 10,
    this.enableRealTrading = false,
    this.useStopLoss = true,
    this.useTakeProfit = true,
    this.defaultStopLossPct = 0.8,
    this.defaultTakeProfitPct = 1.5,
  });

  factory BinanceTradingConfig.fromJson(Map<String, dynamic> json) {
    return BinanceTradingConfig(
      userId: json['userId'] ?? '',
      tradeAmountUsdt: (json['tradeAmountUsdt'] ?? 10.0).toDouble(),
      leverage: json['leverage'] ?? 1,
      orderType: json['orderType'] ?? 'MARKET',
      maxSlippagePercent: (json['maxSlippagePercent'] ?? 0.5).toDouble(),
      maxDailyLossUsdt: (json['maxDailyLossUsdt'] ?? 100.0).toDouble(),
      maxDailyTrades: json['maxDailyTrades'] ?? 10,
      enableRealTrading: json['enableRealTrading'] ?? false,
      useStopLoss: json['useStopLoss'] ?? true,
      useTakeProfit: json['useTakeProfit'] ?? true,
      defaultStopLossPct: (json['defaultStopLossPct'] ?? 0.8).toDouble(),
      defaultTakeProfitPct: (json['defaultTakeProfitPct'] ?? 1.5).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'tradeAmountUsdt': tradeAmountUsdt,
      'leverage': leverage,
      'orderType': orderType,
      'maxSlippagePercent': maxSlippagePercent,
      'maxDailyLossUsdt': maxDailyLossUsdt,
      'maxDailyTrades': maxDailyTrades,
      'enableRealTrading': enableRealTrading,
      'useStopLoss': useStopLoss,
      'useTakeProfit': useTakeProfit,
      'defaultStopLossPct': defaultStopLossPct,
      'defaultTakeProfitPct': defaultTakeProfitPct,
    };
  }
}

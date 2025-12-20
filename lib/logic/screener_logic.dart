import '../services/binance_service.dart';
import '../indicators/ema.dart';
import '../indicators/rsi.dart';
import '../indicators/vwap.dart';
import '../indicators/bollinger.dart';
import '../indicators/atr.dart';
import '../market/pivots.dart';
import '../scoring/features.dart';
import '../scoring/score.dart';
import '../scoring/status.dart';
import '../models/coin_data.dart';

class ScreenerLogic {
  final BinanceService _binance = BinanceService();

  Future<List<CoinData>> scan({int limit = 30}) async {
    // 1. Get Universe (Futures + Spot + Active symbols)
    final resultsTickers = await Future.wait([
      _binance.getFutures24hrTicker(),
      _binance.getSpot24hrTicker(),
      _binance.getActiveTradingSymbols(),
    ]);

    final futuresTickers = resultsTickers[0] as List<Ticker24h>;
    final spotTickers = resultsTickers[1] as List<Ticker24h>;
    final activeSymbols = resultsTickers[2] as Set<String>;

    final Map<String, Ticker24h> spotMap = {
      for (final t in spotTickers) t.symbol: t,
    };

    // Sort by QuoteVolume and Filter USDT Perpetual only
    // Exclude delivery futures (contains '_') and only include perpetual contracts
    // Also filter only TRADING status symbols
    final candidates =
        futuresTickers
            .where((t) => t.symbol.endsWith('USDT'))
            .where(
              (t) => !t.symbol.contains('_'),
            ) // Exclude delivery futures with expiry dates
            .where(
              (t) => activeSymbols.contains(t.symbol),
            ) // Only TRADING status
            .where(
              (t) => (double.tryParse(t.quoteVolume) ?? 0) > 50000000,
            ) // 50M
            .toList()
          ..sort(
            (a, b) => (double.tryParse(b.quoteVolume) ?? 0).compareTo(
              double.tryParse(a.quoteVolume) ?? 0,
            ),
          );

    final topCandidates = candidates.take(limit).toList();

    List<CoinData> results = [];

    // Parallel Processing (using Future.wait)
    // Note: Dart is single threaded, but I/O is async.
    // Calculating on main isolate might stutter UI if list is huge,
    // but for 30 items it's fine. run in isolate if needed.

    // 2. Process in small batches to avoid rate limits (matches web batching)
    const int batchSize = 5;
    for (int i = 0; i < topCandidates.length; i += batchSize) {
      final batch = topCandidates.skip(i).take(batchSize).toList();

      final processed = await Future.wait(
        batch.map((ticker) async {
          try {
            final klines = await _binance.getKlines(ticker.symbol, '15m', 500);
            if (klines.length < 200) return null;

            // Parse Data
            final closes = klines
                .map((k) => double.parse(k[4].toString()))
                .toList();
            final highs = klines
                .map((k) => double.parse(k[2].toString()))
                .toList();
            final lows = klines
                .map((k) => double.parse(k[3].toString()))
                .toList();

            // Calculate Indicators
            final ema50 = calculateEMA(closes, 50);
            final rsi = calculateRSI(closes, 14);
            final vwap = calculateVWAP(klines);
            final bb = calculateBollingerBands(closes, 20, 2.0);
            final atr = calculateATR(highs, lows, closes, 14);
            final pivots = findPivotLows(lows, leftBars: 2, rightBars: 2);

            // Spot lookup for basis spread (no per-symbol network call)
            double basisSpread = 0;
            final spotTicker = spotMap[ticker.symbol];
            if (spotTicker != null) {
              final spotLast = double.tryParse(spotTicker.lastPrice) ?? 0;
              final futLast = double.tryParse(ticker.lastPrice) ?? 0;
              if (spotLast > 0 && futLast > 0) {
                basisSpread = ((futLast - spotLast) / spotLast) * 100;
              }
            }

            // Funding rate is optional; keep lightweight to reduce throttling
            final fundingRate = 0.0;

            // Extract Features
            final features = extractFeatures(
              closes,
              highs,
              lows,
              ticker,
              ema50,
              vwap,
              rsi,
              bb,
              atr,
              pivots,
              fundingRate: fundingRate,
            );

            // Score
            final scoreResult = calculateScore(features);
            final status = determineStatus(scoreResult, features);

            return CoinData(
              symbol: ticker.symbol,
              price: double.tryParse(ticker.lastPrice) ?? 0,
              score: scoreResult.totalScore,
              status: status,
              priceChangePercent:
                  double.tryParse(ticker.priceChangePercent) ?? 0,
              fundingRate: fundingRate,
              basisSpread: basisSpread,
              features: features,
            );
          } catch (e) {
            // Per-symbol failures should not drop the whole scan
            print('Error processing ${ticker.symbol}: $e');
            return null;
          }
        }),
      );

      results.addAll(processed.whereType<CoinData>());
    }

    // Sort by Score
    results.sort((a, b) => b.score.compareTo(a.score));

    return results;
  }
}

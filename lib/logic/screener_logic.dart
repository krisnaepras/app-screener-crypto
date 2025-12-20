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
import 'dart:math';

class ScreenerLogic {
  final BinanceService _binance = BinanceService();

  Future<List<CoinData>> scan({int limit = 30}) async {
    // 1. Get Universe
    final futuresTickers = await _binance.getFutures24hrTicker();
    
    // Sort by QuoteVolume and Filter USDT
    final candidates = futuresTickers
        .where((t) => t.symbol.endsWith('USDT'))
        .where((t) => (double.tryParse(t.quoteVolume) ?? 0) > 50000000) // 50M
        .toList()
      ..sort((a, b) => (double.tryParse(b.quoteVolume) ?? 0)
          .compareTo(double.tryParse(a.quoteVolume) ?? 0));

    final topCandidates = candidates.take(limit).toList();

    List<CoinData> results = [];

    // Parallel Processing (using Future.wait)
    // Note: Dart is single threaded, but I/O is async. 
    // Calculating on main isolate might stutter UI if list is huge, 
    // but for 30 items it's fine. run in isolate if needed.

    final futures = topCandidates.map((ticker) async {
      try {
        final klines = await _binance.getKlines(ticker.symbol, '15m', 500);
        if (klines.length < 200) return null;

        // Parse Data
        final closes = klines.map((k) => double.parse(k[4].toString())).toList();
        final highs = klines.map((k) => double.parse(k[2].toString())).toList();
        final lows = klines.map((k) => double.parse(k[3].toString())).toList();

        // Calculate Indicators
        final ema50 = calculateEMA(closes, 50);
        final rsi = calculateRSI(closes, 14);
        final vwap = calculateVWAP(klines);
        final bb = calculateBollingerBands(closes, 20, 2.0);
        final atr = calculateATR(highs, lows, closes, 14);
        final pivots = findPivotLows(lows, leftBars: 2, rightBars: 2);
        
        // Funding Rate (Optional: fetch parallel or skip to save time)
        // For MVP speed, let's skip extra request or do it
        // let fundingRate = 0.0; 
        
        // Extract Features
        final features = extractFeatures(
          closes, highs, lows, ticker, ema50, vwap, rsi, bb, atr, pivots
        );

        // Score
        final scoreResult = calculateScore(features);
        final status = determineStatus(scoreResult, features);

        return CoinData(
          symbol: ticker.symbol,
          price: double.parse(ticker.lastPrice),
          score: scoreResult.totalScore,
          status: status,
          priceChangePercent: double.parse(ticker.priceChangePercent),
          fundingRate: 0, // features.fundingRate
        );
      } catch (e) {
        print('Error processing ${ticker.symbol}: $e');
        return null;
      }
    });

    final processed = await Future.wait(futures);
    results = processed.whereType<CoinData>().toList();
    
    // Sort by Score
    results.sort((a, b) => b.score.compareTo(a.score));

    return results;
  }
}

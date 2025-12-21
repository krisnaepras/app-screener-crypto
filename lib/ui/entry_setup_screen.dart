import 'package:flutter/material.dart';
import '../models/coin_data.dart';
import '../models/trade_entry.dart';
import '../logic/screener_logic.dart';
import '../services/trade_service.dart';
import 'dart:async';
import 'widgets/entry_card.dart';

class EntrySetupScreen extends StatefulWidget {
  const EntrySetupScreen({super.key});

  @override
  State<EntrySetupScreen> createState() => _EntrySetupScreenState();
}

class _EntrySetupScreenState extends State<EntrySetupScreen> {
  List<CoinData> _topCoins = [];
  bool _isLoading = true;
  final ScreenerLogic _screenerLogic = ScreenerLogic();
  StreamSubscription<List<CoinData>>? _coinSubscription;
  String? _selectedCoinSymbol;

  @override
  void initState() {
    super.initState();
    _loadTopCoins();
  }

  @override
  void dispose() {
    _coinSubscription?.cancel();
    _screenerLogic.dispose();
    super.dispose();
  }

  void _loadTopCoins() {
    setState(() => _isLoading = true);

    _coinSubscription?.cancel();
    _coinSubscription = _screenerLogic.coinStream.listen(
      (coins) {
        coins.sort((a, b) => b.score.compareTo(a.score));
        setState(() {
          _topCoins = coins.take(5).toList();
          _isLoading = false;
        });
      },
      onError: (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
        }
      },
    );
  }

  void _createEntry(CoinData coin) {
    // Calculate entry levels
    final entryPrice = coin.price;
    final sl = entryPrice * 1.006; // 0.6% stop loss for SHORT
    final tp1 = entryPrice * 0.992; // 0.8%
    final tp2 = entryPrice * 0.985; // 1.5%
    final tp3 = entryPrice * 0.975; // 2.5%

    // Show confirm dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Entry ${coin.symbol} SHORT?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLevelInfo('Entry', entryPrice),
            _buildLevelInfo('SL', sl, isLoss: true),
            _buildLevelInfo('TP1', tp1),
            _buildLevelInfo('TP2', tp2),
            _buildLevelInfo('TP3', tp3),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _submitEntry(coin, entryPrice, sl, tp1, tp2, tp3);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm Entry'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitEntry(
    CoinData coin,
    double entryPrice,
    double sl,
    double tp1,
    double tp2,
    double tp3,
  ) async {
    setState(() => _isLoading = true);
    try {
      print('Creating entry for ${coin.symbol}...');
      final rsiValue = coin.features?.rsi ?? 0;
      final reason =
          '1m: Overbought (RSI ${rsiValue.toStringAsFixed(0)}%) | 5m: Breakdown signal';

      print('Calling TradeService.createEntry...');
      final entry = await TradeService.createEntry(
        symbol: coin.symbol,
        isLong: false,
        entryPrice: entryPrice,
        stopLoss: sl,
        takeProfit1: tp1,
        takeProfit2: tp2,
        takeProfit3: tp3,
        entryReason: reason,
      );

      print('Entry created successfully: ${entry.id}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Entry ${coin.symbol} created'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error creating entry: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildLevelInfo(String label, double price, {bool isLoss = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isLoss ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('\$${price.toStringAsFixed(4)}'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _loadTopCoins();
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _topCoins.isEmpty
            ? const Center(child: Text('No data available'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _topCoins.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      EntryCard(coin: _topCoins[index], index: index),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: FloatingActionButton.small(
                          heroTag: 'entry_${index}',
                          onPressed: () => _createEntry(_topCoins[index]),
                          backgroundColor: Colors.green,
                          child: const Icon(Icons.add),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

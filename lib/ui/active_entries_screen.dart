import 'package:flutter/material.dart';
import '../models/trade_entry.dart';
import '../services/trade_service.dart';
import '../services/price_stream_service.dart';
import 'widgets/active_trade_card.dart';

class ActiveEntriesScreen extends StatefulWidget {
  const ActiveEntriesScreen({super.key});

  @override
  State<ActiveEntriesScreen> createState() => _ActiveEntriesScreenState();
}

class _ActiveEntriesScreenState extends State<ActiveEntriesScreen> {
  List<TradeEntry> _activeEntries = [];
  bool _isLoading = true;
  final PriceStreamService _priceService = PriceStreamService();
  Map<String, double> _currentPrices = {};

  @override
  void initState() {
    super.initState();
    _loadActiveEntries();
    _subscribeToRealTimePrices();
  }

  void _subscribeToRealTimePrices() {
    _priceService.getPriceStream().listen(
      (prices) {
        if (mounted) {
          setState(() {
            _currentPrices = prices;
          });
        }
      },
      onError: (error) {
        print('Price stream error: $error');
      },
    );
  }

  @override
  void dispose() {
    _priceService.close();
    super.dispose();
  }

  Future<void> _loadActiveEntries() async {
    setState(() => _isLoading = true);
    try {
      final entries = await TradeService.getActiveEntries();
      setState(() {
        _activeEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading entries: $e')));
      }
    }
  }

  void _closeEntry(TradeEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Close ${entry.symbol}?'),
        content: const Text('Apakah Anda yakin ingin menutup posisi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _submitCloseEntry(entry);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitCloseEntry(TradeEntry entry) async {
    setState(() => _isLoading = true);
    try {
      // Use real-time price if available, fallback to mock
      final currentPrice =
          _currentPrices[entry.symbol] ?? entry.entryPrice * 0.997;
      final pl =
          (entry.entryPrice - currentPrice) * 10; // Assuming 10 position size

      await TradeService.updateEntry(
        id: entry.id,
        status: 'closed',
        exitPrice: currentPrice,
      );

      await _loadActiveEntries();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${entry.symbol} ditutup | P/L: \$${pl.toStringAsFixed(2)}',
            ),
            backgroundColor: pl >= 0 ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadActiveEntries,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _activeEntries.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada entry aktif',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Entry akan muncul di sini setelah Anda masuk posisi',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _activeEntries.length,
                itemBuilder: (context, index) {
                  final entry = _activeEntries[index];
                  final currentPrice = _currentPrices[entry.symbol];

                  return ActiveTradeCard(
                    entry: entry,
                    currentPrice: currentPrice, // Pass real-time price
                    onClose: () => _closeEntry(entry),
                  );
                },
              ),
      ),
    );
  }
}

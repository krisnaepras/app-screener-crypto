import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../models/coin_data.dart';
import '../logic/screener_logic.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Use local logic instance for manual refresh, 
  // but stream for background updates if we want to listen to service.
  final ScreenerLogic _logic = ScreenerLogic();
  
  // Mix of Future and Stream?
  // Let's just use FutureBuilder for now for simplicity, 
  // OR listen to service updates for "Realtime" feel.
  
  List<CoinData>? _coins;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // Listen to background service updates
    FlutterBackgroundService().on('update').listen((event) {
      if (event != null && event['data'] != null) {
        final List<dynamic> list = event['data'] as List<dynamic>;
        if (mounted) {
          setState(() {
             _coins = list.map((json) => CoinData.fromJson(Map<String, dynamic>.from(json))).toList();
             _isLoading = false;
          });
        }
      }
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final coins = await _logic.scan();
      if (mounted) {
        setState(() {
          _coins = coins;
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'TRIGGER':
        return Colors.redAccent;
      case 'SETUP':
        return Colors.orangeAccent;
      case 'WATCH':
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screener Micin App (Mandiri)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _coins == null || _coins!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No Data / Error'),
                      ElevatedButton(
                        onPressed: _loadData, 
                        child: const Text('Retry')
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _coins!.length,
                  itemBuilder: (context, index) {
                    final coin = _coins![index];
                    final color = _getStatusColor(coin.status);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color,
                          child: Text(
                            coin.status[0],
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        title: Text(
                          coin.symbol.replaceAll('USDT', ''),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          children: [
                            Text('Score: ${coin.score.toStringAsFixed(0)}'),
                            const SizedBox(width: 8),
                            Text(
                              '${coin.priceChangePercent.toStringAsFixed(2)}%',
                              style: TextStyle(
                                color: coin.priceChangePercent >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           crossAxisAlignment: CrossAxisAlignment.end,
                           children: [
                             Text(
                               '\$${coin.price > 1 ? coin.price.toStringAsFixed(2) : coin.price.toStringAsFixed(5)}',
                               style: const TextStyle(fontWeight: FontWeight.bold),
                             ),
                             Text(
                               coin.status,
                               style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                             )
                           ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'entry_setup_screen.dart';
import 'intraday_setup_screen.dart';
import 'pullback_setup_screen.dart';
import 'breakout_setup_screen.dart';
import 'rsi_screen.dart';
import '../models/coin_data.dart';
import '../services/api_service.dart';
import 'dart:async';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  List<CoinData> _coins = [];
  final ApiService _apiService = ApiService();
  StreamSubscription? _coinSubscription;

  @override
  void initState() {
    super.initState();
    _initWebSocket();
  }

  void _initWebSocket() {
    _coinSubscription?.cancel();
    _coinSubscription = _apiService.getCoinStream().listen(
      (coins) {
        if (mounted) {
          setState(() {
            _coins = coins;
          });
        }
      },
      onError: (e) {
        print('WebSocket error: $e');
        // Retry after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) _initWebSocket();
        });
      },
    );
  }

  @override
  void dispose() {
    _coinSubscription?.cancel();
    _apiService.close();
    super.dispose();
  }

  List<Widget> get _screens => [
    const HomeScreen(),
    const EntrySetupScreen(),
    IntradaySetupScreen(coins: _coins, onRefresh: () => _initWebSocket()),
    PullbackSetupScreen(coins: _coins, onRefresh: () => _initWebSocket()),
    BreakoutSetupScreen(coins: _coins, onRefresh: () => _initWebSocket()),
    const RsiScreen(),
  ];

  final List<String> _screenTitles = [
    'Home',
    'Scalping Setup (1m)',
    'Intraday SHORT (15m+1h)',
    'Pullback Entry (Buy Dip)',
    'Breakout Hunter (15m+1h)',
    'RSI Screener',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close drawer after selection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_screenTitles[_selectedIndex]), elevation: 2),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 48,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Screener Micin',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              selected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Scalping Setup (1m)'),
              selected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.trending_down, color: Colors.red),
              title: const Text('Intraday SHORT (15m+1h)'),
              subtitle: const Text('Short setup 1-4 jam'),
              selected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_circle_up, color: Colors.green),
              title: const Text('Pullback Entry (Buy Dip)'),
              subtitle: const Text('Buy the dip di uptrend'),
              selected: _selectedIndex == 3,
              onTap: () => _onItemTapped(3),
            ),
            ListTile(
              leading: const Icon(Icons.rocket_launch, color: Colors.blue),
              title: const Text('Breakout Hunter'),
              subtitle: const Text('Breakout + volume spike'),
              selected: _selectedIndex == 4,
              onTap: () => _onItemTapped(4),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.show_chart_outlined),
              title: const Text('RSI Screener'),
              selected: _selectedIndex == 5,
              onTap: () => _onItemTapped(5),
            ),
            ListTile(
              leading: const Icon(Icons.info_outlined),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Screener Micin',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.show_chart, size: 48),
                  children: [
                    const Text(
                      'Cryptocurrency screener app with RSI and scalping indicators.',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}

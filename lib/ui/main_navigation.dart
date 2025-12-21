import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'entry_setup_screen.dart';
import 'active_entries_screen.dart';
import 'history_screen.dart';
import 'rsi_screen.dart';
import 'scalping_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const EntrySetupScreen(),
    const ActiveEntriesScreen(),
    const HistoryScreen(),
    const RsiScreen(),
    const ScalpingScreen(),
  ];

  final List<String> _screenTitles = [
    'Home',
    'Entry Setup (1m)',
    'Entry Berjalan',
    'Riwayat',
    'RSI Screener',
    'Scalping',
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
              title: const Text('Entry Setup (1m)'),
              selected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.play_circle_outline),
              title: const Text('Entry Berjalan'),
              selected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Riwayat'),
              selected: _selectedIndex == 3,
              onTap: () => _onItemTapped(3),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.show_chart_outlined),
              title: const Text('RSI Screener'),
              selected: _selectedIndex == 4,
              onTap: () => _onItemTapped(4),
            ),
            ListTile(
              leading: const Icon(Icons.flash_on_outlined),
              title: const Text('Scalping'),
              selected: _selectedIndex == 5,
              onTap: () => _onItemTapped(5),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon')),
                );
              },
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

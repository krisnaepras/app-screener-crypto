import 'package:flutter/material.dart';
import '../services/auto_scalp_service.dart';
import '../services/price_stream_service.dart';
import '../models/auto_scalp_entry.dart';
import '../models/auto_scalp_settings.dart';

class ScalpingScreen extends StatefulWidget {
  const ScalpingScreen({super.key});

  @override
  State<ScalpingScreen> createState() => _ScalpingScreenState();
}

class _ScalpingScreenState extends State<ScalpingScreen> {
  final AutoScalpService _service = AutoScalpService();
  final PriceStreamService _priceService = PriceStreamService();
  AutoScalpSettings? _settings;
  String _selectedPeriod = '1d';
  bool _isLoading = true;
  Stream<List<AutoScalpEntry>>? _activePositionsStream;
  Stream<Map<String, double>>? _priceStream;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _activePositionsStream = Stream.periodic(
      const Duration(seconds: 3),
    ).asyncMap((_) => _service.getActivePositions()).asBroadcastStream();
    _priceStream = _priceService.getPriceStream();
  }

  @override
  void dispose() {
    _priceService.close();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final settings = await _service.getSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _toggleAutoScalping(bool enabled) async {
    try {
      _settings!.enabled = enabled;
      await _service.updateSettings(_settings!);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled ? '✓ Auto Scalping AKTIF' : '⏸ Auto Scalping NONAKTIF',
            ),
            backgroundColor: enabled ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _SettingsDialog(
        settings: _settings!,
        onSave: (newSettings) async {
          try {
            await _service.updateSettings(newSettings);
            setState(() => _settings = newSettings);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✓ Settings tersimpan')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_settings == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Gagal memuat settings'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSettings,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: [
              const Text(
                'Auto Scalping SHORT',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _settings!.enabled ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _settings!.enabled ? 'ON' : 'OFF',
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Settings',
                icon: const Icon(Icons.settings),
                onPressed: _showSettingsDialog,
              ),
            ],
          ),
        ),

        // Control Panel
        _buildControlPanel(),
        const Divider(height: 1),

        // Stats & History
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Active'),
                    Tab(text: 'History'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [_buildActiveTab(), _buildHistoryTab()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[900],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status Sistem',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        _settings!.enabled
                            ? Icons.play_circle
                            : Icons.pause_circle,
                        color: _settings!.enabled ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _settings!.enabled ? 'Aktif Memantau' : 'Nonaktif',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _settings!.enabled
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: _settings!.enabled,
                onChanged: _toggleAutoScalping,
                activeColor: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(
                'Max Trades',
                _settings!.maxConcurrentTrades.toString(),
                Icons.bar_chart,
              ),
              const SizedBox(width: 8),
              _buildInfoChip('RSI Filter', '75+', Icons.trending_up),
              const SizedBox(width: 8),
              _buildInfoChip(
                'SL',
                '${_settings!.stopLossPercent.toStringAsFixed(1)}%',
                Icons.shield,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.blue),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTab() {
    return StreamBuilder<List<AutoScalpEntry>>(
      stream: _activePositionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final entries = snapshot.data ?? [];
        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[700]),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada posisi aktif',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  _settings!.enabled
                      ? 'Sistem sedang menunggu setup optimal...'
                      : 'Aktifkan Auto Scalping untuk mulai',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) => _ActiveTradeCard(
            entry: entries[index],
            priceStream: _priceStream ?? Stream.value({}),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        // Period filter
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              _buildPeriodChip('1 Hari', '1d'),
              _buildPeriodChip('1 Minggu', '7d'),
              _buildPeriodChip('1 Bulan', '30d'),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _service.getHistory(_selectedPeriod),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final data = snapshot.data!;
              final entries = data['history'] as List<AutoScalpEntry>;
              final stats = data['stats'] as Map<String, dynamic>;

              // Sort by exit time (most recent first)
              entries.sort((a, b) {
                final aTime = a.exitTime ?? a.entryTime;
                final bTime = b.exitTime ?? b.entryTime;
                return bTime.compareTo(aTime);
              });

              return Column(
                children: [
                  _buildStatsCard(stats),
                  Expanded(
                    child: entries.isEmpty
                        ? Center(
                            child: Text(
                              'Belum ada riwayat',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: entries.length,
                            itemBuilder: (context, index) =>
                                _HistoryTradeCard(entry: entries[index]),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey[850],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    final totalTrades = stats['totalTrades'] ?? 0;
    final winRate = stats['winRate'] ?? 0.0;
    final totalProfit = stats['totalProfitPct'] ?? 0.0;
    final avgDuration = stats['avgDuration'] ?? 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Statistik',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Trades', totalTrades.toString(), Colors.blue),
              _buildStatItem(
                'Win Rate',
                '${winRate.toStringAsFixed(1)}%',
                winRate >= 50 ? Colors.green : Colors.red,
              ),
              _buildStatItem(
                'Total P/L',
                '${totalProfit >= 0 ? '+' : ''}${totalProfit.toStringAsFixed(2)}%',
                totalProfit >= 0 ? Colors.green : Colors.red,
              ),
              _buildStatItem(
                'Avg Time',
                '${(avgDuration / 60).toStringAsFixed(0)}m',
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// Settings Dialog
class _SettingsDialog extends StatefulWidget {
  final AutoScalpSettings settings;
  final Function(AutoScalpSettings) onSave;

  const _SettingsDialog({required this.settings, required this.onSave});

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  late AutoScalpSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = AutoScalpSettings.fromJson(widget.settings.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Auto Scalping Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSlider(
              'Max Concurrent Trades',
              _settings.maxConcurrentTrades.toDouble(),
              1,
              5,
              (value) =>
                  setState(() => _settings.maxConcurrentTrades = value.toInt()),
              suffix: ' trades',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Entry: RSI 75+ dengan 2+ tanda reversal\n(rejection wick, above BB, EMA overext, breakdown, funding rate, pump 15%+)',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
            _buildSlider(
              'Stop Loss %',
              _settings.stopLossPercent,
              0.3,
              1.0,
              (value) => setState(() => _settings.stopLossPercent = value),
              suffix: '%',
              divisions: 14,
            ),
            // Hidden settings (handled automatically)
            /*
            _buildSlider(
              'Min Profit to Trail %',
              _settings.minProfitPercent,
              0.2,
              0.8,
              (value) => setState(() => _settings.minProfitPercent = value),
              suffix: '%',
              divisions: 12,
            ),
            _buildSlider(
              'Trailing Stop %',
              _settings.trailingStopPercent,
              0.1,
              0.4,
              (value) => setState(() => _settings.trailingStopPercent = value),
              suffix: '%',
              divisions: 12,
            ),
            */
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_settings);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged, {
    String suffix = '',
    int? divisions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            Text(
              '${value.toStringAsFixed(value >= 10 ? 0 : 1)}$suffix',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions ?? ((max - min) * 10).toInt(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// Active Trade Card
class _ActiveTradeCard extends StatelessWidget {
  final AutoScalpEntry entry;
  final Stream<Map<String, double>> priceStream;

  const _ActiveTradeCard({required this.entry, required this.priceStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, double>>(
      stream: priceStream,
      builder: (context, priceSnapshot) {
        // Get current price for this symbol
        final currentPrice =
            priceSnapshot.data?[entry.symbol] ?? entry.entryPrice;

        // Calculate unrealized P/L (SHORT position: profit when price goes down)
        final priceDiff = entry.entryPrice - currentPrice;
        final currentPLPct = (priceDiff / entry.entryPrice) * 100;

        // Calculate time elapsed in real-time
        return StreamBuilder(
          stream: Stream.periodic(const Duration(seconds: 1)),
          builder: (context, _) {
            final duration = DateTime.now().difference(entry.entryTime);
            final durationText = duration.inHours > 0
                ? '${duration.inHours}h ${duration.inMinutes % 60}m ago'
                : '${duration.inMinutes}m ago';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.symbol,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          durationText,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Entry',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '\$${entry.entryPrice.toStringAsFixed(4)}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '\$${currentPrice.toStringAsFixed(4)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SL',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '\$${entry.stopLoss.toStringAsFixed(4)}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Unrealized P/L',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${currentPLPct >= 0 ? '+' : ''}${currentPLPct.toStringAsFixed(2)}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: currentPLPct >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// History Trade Card
class _HistoryTradeCard extends StatelessWidget {
  final AutoScalpEntry entry;

  const _HistoryTradeCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final duration = (entry.durationSeconds / 60).toStringAsFixed(0);
    final plPct = entry.profitLossPct ?? 0.0;
    final exitReason = _getExitReasonText(entry.exitReason);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.symbol,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$exitReason • ${duration}m',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${plPct >= 0 ? '+' : ''}${plPct.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: plPct >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  '\$${(entry.profitLoss ?? 0).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: plPct >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getExitReasonText(String reason) {
    switch (reason) {
      case 'TP_HIT':
        return 'TP Hit';
      case 'SL_HIT':
        return 'Stop Loss';
      case 'TRAILING_STOP':
        return 'Trailing Stop';
      case 'MAX_TIME':
        return 'Max Time';
      case 'EMERGENCY_EXIT':
        return 'Emergency';
      default:
        return reason;
    }
  }
}

import 'package:flutter/material.dart';
import '../models/trade_entry.dart';
import '../services/trade_service.dart';
import 'widgets/history_trade_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filterStatus = 'all'; // all, profit, loss
  List<TradeEntry> _historyEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final entries = await TradeService.getHistory();
      setState(() {
        _historyEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading history: $e')));
      }
    }
  }

  List<TradeEntry> get _filteredEntries {
    if (_filterStatus == 'all') return _historyEntries;
    if (_filterStatus == 'profit') {
      return _historyEntries
          .where((e) => e.profitLoss != null && e.profitLoss! > 0)
          .toList();
    }
    return _historyEntries
        .where((e) => e.profitLoss != null && e.profitLoss! < 0)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalPL = _historyEntries.fold<double>(
      0,
      (sum, entry) => sum + (entry.profitLoss ?? 0),
    );
    final winCount = _historyEntries
        .where((e) => e.profitLoss != null && e.profitLoss! > 0)
        .length;
    final winRate = _historyEntries.isEmpty
        ? 0.0
        : (winCount / _historyEntries.length);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                    'Total P/L',
                    '\$${totalPL.toStringAsFixed(2)}',
                    totalPL >= 0 ? Colors.green : Colors.red,
                  ),
                  _buildStatCard(
                    'Win Rate',
                    '${(winRate * 100).toStringAsFixed(1)}%',
                    winRate >= 0.5 ? Colors.green : Colors.orange,
                  ),
                  _buildStatCard(
                    'Total Trades',
                    '${_historyEntries.length}',
                    Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildFilterChip('Semua', 'all')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildFilterChip('Profit', 'profit')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildFilterChip('Loss', 'loss')),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredEntries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada riwayat',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredEntries.length,
                    itemBuilder: (context, index) {
                      return HistoryTradeCard(entry: _filteredEntries[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

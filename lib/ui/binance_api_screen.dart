import 'package:flutter/material.dart';
import '../services/binance_api_service.dart';
import '../models/binance_api_models.dart';

class BinanceAPIScreen extends StatefulWidget {
  const BinanceAPIScreen({super.key});

  @override
  State<BinanceAPIScreen> createState() => _BinanceAPIScreenState();
}

class _BinanceAPIScreenState extends State<BinanceAPIScreen> {
  final BinanceAPIService _service = BinanceAPIService();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _secretKeyController = TextEditingController();
  final TextEditingController _tradeAmountController = TextEditingController();
  final TextEditingController _leverageController = TextEditingController();

  bool _isLoading = true;
  bool _hasCredentials = false;
  bool _isTestnet = false;
  bool _isEnabled = true;
  bool _showApiKey = false;
  bool _showSecretKey = false;
  bool _isSaving = false;

  BinanceAccountInfo? _accountInfo;
  BinanceTradingConfig? _tradingConfig;
  Map<String, dynamic>? _connectionStatus;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _secretKeyController.dispose();
    _tradeAmountController.dispose();
    _leverageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Check if credentials exist
      final credStatus = await _service.getCredentialsStatus();
      final hasCredentials = credStatus['exists'] == true;

      setState(() {
        _hasCredentials = hasCredentials;
        if (hasCredentials) {
          _apiKeyController.text = credStatus['apiKey'] ?? '';
          _isTestnet = credStatus['isTestnet'] ?? false;
          _isEnabled = credStatus['isEnabled'] ?? true;
        }
      });

      // Load trading config and account info if credentials exist
      if (hasCredentials) {
        final config = await _service.getTradingConfig();
        try {
          final accountInfo = await _service.getAccountInfo();
          final connStatus = await _service.testConnection();
          setState(() {
            _tradingConfig = config;
            _accountInfo = accountInfo;
            _connectionStatus = connStatus;
          });
        } catch (e) {
          setState(() {
            _tradingConfig = config;
          });
        }
      } else {
        // Load default config
        final config = await _service.getTradingConfig();
        setState(() {
          _tradingConfig = config;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCredentials() async {
    if (_apiKeyController.text.isEmpty || _secretKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final result = await _service.saveCredentials(
        apiKey: _apiKeyController.text.trim(),
        secretKey: _secretKeyController.text.trim(),
        isTestnet: _isTestnet,
        isEnabled: _isEnabled,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ ${result['message']}'),
            backgroundColor: Colors.green,
          ),
        );
        _secretKeyController.clear();
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteCredentials() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete API Credentials?'),
        content: const Text(
          'This will remove your Binance API keys from the server. You can add them again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deleteCredentials();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✓ Credentials deleted')),
          );
          _apiKeyController.clear();
          _secretKeyController.clear();
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _testConnection() async {
    try {
      final result = await _service.testConnection();
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  result['connected'] ? Icons.check_circle : Icons.error,
                  color: result['connected'] ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(result['connected'] ? 'Connected' : 'Failed'),
              ],
            ),
            content: result['connected']
                ? Text(
                    'Balance: \$${result['balance']?.toStringAsFixed(2)}\nPositions: ${result['positions']}',
                  )
                : Text('Error: ${result['error']}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Connection test failed: $e')));
      }
    }
  }

  Future<void> _saveTradingConfig() async {
    if (_tradingConfig == null) return;

    try {
      await _service.saveTradingConfig(_tradingConfig!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Trading config saved'),
            backgroundColor: Colors.green,
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // API Credentials Section
          _buildSectionTitle('API Credentials'),
          _buildCredentialsSection(),
          const SizedBox(height: 20),

          // Account Info Section (if connected)
          if (_hasCredentials && _accountInfo != null) ...[
            _buildSectionTitle('Account Information'),
            _buildAccountInfoSection(),
            const SizedBox(height: 20),
          ],

          // Trading Configuration Section
          if (_tradingConfig != null) ...[
            _buildSectionTitle('Trading Configuration'),
            _buildTradingConfigSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCredentialsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API Key
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                labelText: 'API Key',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showApiKey ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _showApiKey = !_showApiKey),
                ),
              ),
              obscureText: !_showApiKey,
              enabled: !_hasCredentials,
            ),
            const SizedBox(height: 16),

            // Secret Key
            if (!_hasCredentials)
              TextField(
                controller: _secretKeyController,
                decoration: InputDecoration(
                  labelText: 'Secret Key',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showSecretKey ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _showSecretKey = !_showSecretKey),
                  ),
                ),
                obscureText: !_showSecretKey,
              ),
            if (!_hasCredentials) const SizedBox(height: 16),

            // Testnet toggle
            SwitchListTile(
              title: const Text('Use Testnet'),
              subtitle: const Text('For testing without real money'),
              value: _isTestnet,
              onChanged: _hasCredentials
                  ? null
                  : (value) => setState(() => _isTestnet = value),
            ),

            // Enable toggle
            SwitchListTile(
              title: const Text('Enable Trading'),
              subtitle: const Text('Allow real trading with this API'),
              value: _isEnabled,
              onChanged: (value) => setState(() => _isEnabled = value),
            ),

            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                if (_hasCredentials) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _testConnection,
                      icon: const Icon(Icons.wifi),
                      label: const Text('Test Connection'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _deleteCredentials,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete Credentials',
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveCredentials,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save & Test'),
                    ),
                  ),
                ],
              ],
            ),

            // Connection Status
            if (_connectionStatus != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _connectionStatus!['connected']
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _connectionStatus!['connected']
                          ? Icons.check_circle
                          : Icons.error,
                      color: _connectionStatus!['connected']
                          ? Colors.green
                          : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _connectionStatus!['connected']
                          ? 'Connected'
                          : 'Not Connected',
                      style: TextStyle(
                        fontSize: 12,
                        color: _connectionStatus!['connected']
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              'Total Balance',
              '\$${_accountInfo!.totalBalance.toStringAsFixed(2)}',
            ),
            _buildInfoRow(
              'Available',
              '\$${_accountInfo!.availableBalance.toStringAsFixed(2)}',
            ),
            _buildInfoRow(
              'USDT Balance',
              '\$${_accountInfo!.usdtBalance.toStringAsFixed(2)}',
            ),
            _buildInfoRow('Open Orders', '${_accountInfo!.openOrdersCount}'),
            _buildInfoRow('Open Positions', '${_accountInfo!.positionsCount}'),
            if (_accountInfo!.totalUnrealizedPL != 0)
              _buildInfoRow(
                'Unrealized P/L',
                '\$${_accountInfo!.totalUnrealizedPL.toStringAsFixed(2)}',
                color: _accountInfo!.totalUnrealizedPL >= 0
                    ? Colors.green
                    : Colors.red,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTradingConfigSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trade Amount - Manual Input
            TextField(
              controller: _tradeAmountController
                ..text = _tradingConfig!.tradeAmountUsdt.toString(),
              decoration: const InputDecoration(
                labelText: 'Trade Amount (USDT)',
                helperText: 'Amount per position (e.g., 2.5, 10, 50)',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) {
                final amount = double.tryParse(value);
                if (amount != null && amount > 0) {
                  _tradingConfig!.tradeAmountUsdt = amount;
                }
              },
            ),
            const SizedBox(height: 16),

            // Leverage - Manual Input
            TextField(
              controller: _leverageController
                ..text = _tradingConfig!.leverage.toString(),
              decoration: const InputDecoration(
                labelText: 'Leverage',
                helperText: '1-20x (Higher = Higher Risk)',
                border: OutlineInputBorder(),
                suffixText: 'x',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final leverage = int.tryParse(value);
                if (leverage != null && leverage >= 1 && leverage <= 20) {
                  _tradingConfig!.leverage = leverage;
                }
              },
            ),
            const SizedBox(height: 16),

            _buildSlider(
              'Max Daily Loss (USDT)',
              _tradingConfig!.maxDailyLossUsdt,
              10,
              1000,
              (value) =>
                  setState(() => _tradingConfig!.maxDailyLossUsdt = value),
              divisions: 99,
            ),
            _buildSlider(
              'Max Daily Trades',
              _tradingConfig!.maxDailyTrades.toDouble(),
              1,
              50,
              (value) => setState(
                () => _tradingConfig!.maxDailyTrades = value.toInt(),
              ),
              divisions: 49,
            ),
            _buildSlider(
              'Stop Loss %',
              _tradingConfig!.defaultStopLossPct,
              0.1,
              5.0,
              (value) =>
                  setState(() => _tradingConfig!.defaultStopLossPct = value),
              divisions: 49,
            ),

            // Note about TP following auto scalping
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Take Profit follows Auto Scalping settings (Trailing Stop)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Enable Real Trading'),
              subtitle: const Text('⚠️ WARNING: This will use real money'),
              value: _tradingConfig!.enableRealTrading,
              onChanged: (value) {
                if (value) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('⚠️ Enable Real Trading?'),
                      content: const Text(
                        'This will allow the bot to place real orders with your Binance account. Make sure you understand the risks.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(
                              () => _tradingConfig!.enableRealTrading = true,
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Enable'),
                        ),
                      ],
                    ),
                  );
                } else {
                  setState(() => _tradingConfig!.enableRealTrading = false);
                }
              },
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTradingConfig,
                child: const Text('Save Configuration'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged, {
    int? divisions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              value >= 10 ? value.toStringAsFixed(0) : value.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

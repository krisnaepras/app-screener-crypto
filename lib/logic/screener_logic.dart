import 'dart:async';
import '../models/coin_data.dart';
import '../services/api_service.dart';

class ScreenerLogic {
  final ApiService _apiService = ApiService();
  
  Stream<List<CoinData>> get coinStream => _apiService.getCoinStream();

  // Legacy scan method is removed/replaced. 
  // If UI calls scan(), we might return a Future just to satisfy interface or fail
  // But better to update UI.
  // I will keep a method that returns empty list or throws to alert if I missed any UI usage.
  // Or better, I'll remove it and let the compiler help or just update UI concurrently.
  // I'll update UI to use stream.
  
  void dispose() {
    _apiService.close();
  }
}

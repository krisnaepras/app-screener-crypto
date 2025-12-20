import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io';

class FcmService {
  // Backend URL for token registration
  static String get backendUrl {
    if (kIsWeb) {
      return 'https://screener-micin-eu-040b62987c7f.herokuapp.com';
    } else if (Platform.isAndroid) {
      // For local testing: use 10.0.2.2
      // For production: use Heroku URL
      return 'https://screener-micin-eu-040b62987c7f.herokuapp.com';
    } else {
      return 'https://screener-micin-eu-040b62987c7f.herokuapp.com';
    }
  }

  // Register FCM token with backend
  static Future<bool> registerToken(String token) async {
    try {
      final url = Uri.parse('$backendUrl/api/register-token');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Token registered successfully. Total devices: ${data['count']}');
        return true;
      } else {
        print('Failed to register token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error registering token: $e');
      return false;
    }
  }

  // Unregister FCM token from backend
  static Future<bool> unregisterToken(String token) async {
    try {
      final url = Uri.parse('$backendUrl/api/unregister-token');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': token}),
      );

      if (response.statusCode == 200) {
        print('Token unregistered successfully');
        return true;
      } else {
        print('Failed to unregister token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error unregistering token: $e');
      return false;
    }
  }
}

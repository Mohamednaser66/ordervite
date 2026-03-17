import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final baseUrl = 'https://www.ordervite.com/';

  // Register
  Future<String> register(String email, String password, String username,
      String mobile1, String mobile2) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/supplier/register'),
      body: {
        'email': email,
        'password': password,
        'name': username,
        'mobile1': mobile1,
        'mobile2': mobile2,
      },
    );

    return res.body;
  }

  // Login
  Future<String> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/supplier/login'),
      body: {
        'email': email,
        'password': password,
        'token': 'SdxIpaQp!81XS#QP5%w^cTCIV*DYr',
      },
    );

    return res.body;
  }

  // Save token using SharedPreferences
  static Future<void> setToken(
      String token, String refreshToken, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'token': token,
      'refreshToken': refreshToken,
      'type': type,
    };
    await prefs.setString('tokens', jsonEncode(data));
  }

  // Get token
  static Future<Map<String, dynamic>?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('tokens');
    if (jsonString == null) return null;
    return Map<String, dynamic>.from(jsonDecode(jsonString));
  }

  // Remove token
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tokens');
  }
}
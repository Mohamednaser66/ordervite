import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<String?> getString(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  Future<bool> setString(String key, String value) async {
    final prefs = await _prefs;
    return prefs.setString(key, value);
  }

  Future<Map<String, String?>> getUserData() async {
    final prefs = await _prefs;
    return {
      'username': prefs.getString('username'),
      'email': prefs.getString('email'),
      'token': prefs.getString('token'),
      'id': prefs.getString('id'),
    };
  }

  Future<Map<String, String?>> getOrderData() async {
    final prefs = await _prefs;
    return {
      'disLat': prefs.getString('disLat'),
      'sorLat': prefs.getString('sorLat'),
      'disLong': prefs.getString('disLong'),
      'sorlong': prefs.getString('sorlong'),
      'order_id': prefs.getString('order_id'),
    };
  }

  Future<void> saveOrderLocationData({
    required String disLat,
    required String sorLat,
    required String disLong,
    required String sorlong,
    required String orderId,
  }) async {
    final prefs = await _prefs;
    await prefs.setString('disLat', disLat);
    await prefs.setString('sorLat', sorLat);
    await prefs.setString('disLong', disLong);
    await prefs.setString('sorlong', sorlong);
    await prefs.setString('order_id', orderId);
  }
}
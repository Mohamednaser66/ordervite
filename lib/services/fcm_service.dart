import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// Lightweight FCM service that centralizes token management and message
/// streams. The background handler is top-level to satisfy the Firebase API.

const String _kPendingFcmKey = 'pending_fcm_event';

Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kPendingFcmKey,
      message.data.isNotEmpty
          ? jsonEncode(message.data)
          : jsonEncode({'notification': message.notification?.title ?? ''}),
    );
  } catch (e) {
    // ignore errors in background
  }
}

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Stream of foreground messages
  Stream<RemoteMessage> get onMessageStream => FirebaseMessaging.onMessage;

  /// Stream of messages opened from a notification
  Stream<RemoteMessage> get onMessageOpenedAppStream =>
      FirebaseMessaging.onMessageOpenedApp;

  Future<String?> getToken() => _messaging.getToken();

  Future<void> requestPermissions() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  /// Registers the token on the backend. Caller should pass authenticated
  /// headers or token as needed. This example does a simple PUT to the
  /// provided `registerUrl` with body {"api_token": <fcmToken>}.
  Future<bool> registerTokenOnServer(
    String registerUrl,
    String fcmToken,
    Map<String, String> headers,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(registerUrl),
        headers: headers,
        body: {'api_token': fcmToken},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Read a pending background event saved by [fcmBackgroundHandler]. Use
  /// this on app start to handle events delivered while the app wasn't
  /// running or couldn't process them.
  Future<Map<String, dynamic>?> readPendingBackgroundEvent() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPendingFcmKey);
    if (raw == null) return null;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      await prefs.remove(_kPendingFcmKey);
      return data;
    } catch (e) {
      await prefs.remove(_kPendingFcmKey);
      return null;
    }
  }
}

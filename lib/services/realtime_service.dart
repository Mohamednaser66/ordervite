import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// A reusable service that polls REST endpoints and exposes the results as
/// broadcast [Stream]s.  This can be swapped for Firestore snapshots later
/// without changing the UI layer.
class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  final Map<String, Timer> _timers = {};
  final Map<String, StreamController<dynamic>> _controllers = {};

  /// Creates or returns an existing broadcast stream that polls [fetch] every
  /// [interval].  The stream automatically cleans up when the last listener
  /// cancels.
  Stream<T> createPollingStream<T>({
    required String key,
    required Duration interval,
    required Future<T?> Function() fetch,
  }) {
    if (_controllers.containsKey(key)) {
      return _controllers[key]!.stream as Stream<T>;
    }

    late StreamController<T> controller;

    Future<void> doFetch() async {
      try {
        final data = await fetch();
        if (data != null && !controller.isClosed) {
          controller.add(data);
        }
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      }
    }

    controller = StreamController<T>.broadcast(
      onListen: () {
        // immediate first fetch
        doFetch();
        // periodic updates
        _timers[key] = Timer.periodic(interval, (_) => doFetch());
      },
      onCancel: () {
        _timers[key]?.cancel();
        _timers.remove(key);
        controller.close();
        _controllers.remove(key);
      },
    );

    _controllers[key] = controller;
    return controller.stream;
  }

  Stream<List<dynamic>?> getShipperDailyOrdersStream({
    Duration interval = const Duration(seconds: 15),
  }) {
    return createPollingStream<List<dynamic>>(
      key: 'shipper_daily_orders',
      interval: interval,
      fetch: _fetchShipperDailyOrders,
    );
  }

  Stream<Map<String, dynamic>?> getShipperCurrentOrderStream({
    required String shipperId,
    Duration interval = const Duration(seconds: 10),
  }) {
    return createPollingStream<Map<String, dynamic>>(
      key: 'shipper_current_order_$shipperId',
      interval: interval,
      fetch: () => _fetchShipperCurrentOrder(shipperId),
    );
  }

  Stream<Map<String, dynamic>?> getSupplierCurrentOrderStream({
    required String supplierId,
    Duration interval = const Duration(seconds: 10),
  }) {
    return createPollingStream<Map<String, dynamic>>(
      key: 'supplier_current_order_$supplierId',
      interval: interval,
      fetch: () => _fetchSupplierCurrentOrder(supplierId),
    );
  }

  Future<List<dynamic>?> _fetchShipperDailyOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return null;

    try {
      final response = await http.get(
        Uri.parse('https://www.ordervite.com/api/shippier/daily/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] as List<dynamic>?;
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> _fetchShipperCurrentOrder(
    String shipperId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return null;

    try {
      final response = await http.get(
        Uri.parse(
          'https://www.ordervite.com/api/shippier/current_order/$shipperId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] as Map<String, dynamic>?;
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> _fetchSupplierCurrentOrder(
    String supplierId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return null;

    try {
      final response = await http.get(
        Uri.parse(
          'https://www.ordervite.com/api/supplier/current_order/$supplierId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] as Map<String, dynamic>?;
      }
    } catch (_) {}
    return null;
  }

  /// Cancels every active stream.  Call this on logout or app shutdown.
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    for (final ctrl in _controllers.values) {
      ctrl.close();
    }
    _controllers.clear();
  }
}

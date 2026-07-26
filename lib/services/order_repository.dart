import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_maps/config/app_config.dart';
import 'package:flutter_maps/models/order.dart';
import 'package:flutter_maps/supplier/models/finance_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class OrderRepository {
  static const String _baseUrl = '${AppConfig.baseUrl}/supplier';
  static const Duration _pollInterval = Duration(seconds: 10);
  static const Duration _timeout = Duration(seconds: 10);

  StreamController<Order?>? _orderStreamController;
  Timer? _pollTimer;

  /// Alias for backward compatibility with OrderCubit
  Stream<Order> watchOrder(String userId, String token) async* {
    await for (final order in getOrderStream(userId, token)) {
      if (order != null) yield order;
    }
  }

  /// Creates a broadcast stream that polls for the current order.
  Stream<Order?> getOrderStream(String userId, String token) {
    _orderStreamController ??= StreamController<Order?>.broadcast(
      onListen: () {
        _startPolling(userId, token);
      },
      onCancel: () {
        _stopPolling();
      },
    );
    return _orderStreamController!.stream;
  }

  void _startPolling(String userId, String token) {
    _stopPolling();

    _pollTimer = Timer.periodic(_pollInterval, (_) async {
      try {
        final order = await _fetchCurrentOrder(userId, token);
        if (order != null &&
            _orderStreamController != null &&
            !_orderStreamController!.isClosed) {
          _orderStreamController!.add(order);
        }
      } catch (e) {
        if (_orderStreamController != null &&
            !_orderStreamController!.isClosed) {
          _orderStreamController!.addError(e);
        }
      }
    });

    // Trigger initial fetch immediately
    _fetchCurrentOrder(userId, token)
        .then((order) {
          if (order != null &&
              _orderStreamController != null &&
              !_orderStreamController!.isClosed) {
            _orderStreamController!.add(order);
          }
        })
        .catchError((e) {
          if (_orderStreamController != null &&
              !_orderStreamController!.isClosed) {
            _orderStreamController!.addError(e);
          }
        });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Public method to fetch a single order (for refresh operations)
  Future<Order?> getOrder(String userId, String token) async {
    return _fetchCurrentOrder(userId, token);
  }

  Future<Order?> _fetchCurrentOrder(String userId, String token) async {
    try {
      final int parsedId = int.parse(userId);
      final url = '$_baseUrl/current_order/$parsedId';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch order: ${response.statusCode}');
      }

      final json = jsonDecode(response.body);
      final orderData = json['data'];

      if (orderData == null) {
        return null;
      }

      return Order.fromJson(orderData);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch route from Google Maps Directions API
  Future<Map<String, dynamic>?> getRoute(
    LatLng source,
    LatLng destination,
    String apiKey,
  ) async {
    try {
      final url =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${source.latitude},${source.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey";

      final response = await http.get(Uri.parse(url)).timeout(_timeout);

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body);
      if (json['routes'] == null || (json['routes'] as List).isEmpty)
        return null;

      final route = json['routes'][0];
      final encodedPoints = route['overview_polyline']['points'];
      final distanceValue = route['legs'][0]['distance']['value'];
      final distance = (distanceValue / 1000).toStringAsFixed(2);

      return {'encodedPoints': encodedPoints, 'distance': distance};
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch finance configuration
  Future<FinanceConfig?> getFinanceConfig(String token) async {
    try {
      final url = '$_baseUrl/finance';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body);
      if (json['data'] == null) return null;

      return FinanceConfig.fromJson(json['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new order
  Future<Order?> createOrder(
    Map<String, dynamic> orderData,
    String token,
  ) async {
    try {
      final url = '$_baseUrl/orders';

      final response = await http
          .post(
            Uri.parse(url),
            body: orderData,
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);
      debugPrint("STATUS CODE = ${response.statusCode}");
      debugPrint("BODY = ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) return null;


      final json = jsonDecode(response.body);
      if (json['data'] == null) return null;

      return Order.fromJson(json['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Update order state (e.g., "order complete")
  Future<bool> updateOrderState(
    String orderId,
    String state,
    String token,
  ) async {
    try {
      final int parsedId = int.parse(orderId);
      final url = '$_baseUrl/order_update/$parsedId';

      final response = await http
          .put(
            Uri.parse(url),
            body: {"order_state": state},
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> cancelOrder(
    String orderId,
    String cancelMessage,
    String token,
  ) async {
    try {
      final int parsedId = int.parse(orderId);
      final url = '$_baseUrl/order_update/$parsedId';

      final response = await http
          .put(
            Uri.parse(url),
            body: {'order_cancel': cancelMessage},
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getShipperApiToken(String shipperId, String token) async {
    try {
      final int parsedId = int.parse(shipperId);
      final url = '$_baseUrl/shippier/$parsedId';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch shipper: ${response.statusCode}');
      }

      final json = jsonDecode(response.body);
      return json['data']['name']['api_token']?.toString();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateFcmToken(
    String supplierId,
    String fcmToken,
    String token,
  ) async {
    try {
      final int parsedId = int.parse(supplierId);
      final url = '$_baseUrl/complete_profile/$parsedId';

      final response = await http
          .put(
            Uri.parse(url),
            body: {"api_token": fcmToken},
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getUnreadMessagesCount(String orderId, String token) async {
    try {
      final int parsedId = int.parse(orderId);
      final url = '$_baseUrl/order/$parsedId/messages/unread/shipper';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      if (response.statusCode != 200) return 0;

      final json = jsonDecode(response.body);
      return json['data']?['order unread messages count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> sendNotification(
    String text,
    String shipperApiToken,
    String token,
    String type,
  ) async {
    try {
      final url =
          '$_baseUrl/notify/page/ordervite/$text/$shipperApiToken/1/ordervite/supplier/$type';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  /// Notify order cancellation to shipper
  Future<bool> notifyOrderCancellation(
    String text,
    String shipperApiToken,
    String token,
  ) async {
    try {
      final url =
          '$_baseUrl/notify/page/ordervite/$text/$shipperApiToken/1/ordervite/supplier/order cancel';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    _stopPolling();
    _orderStreamController?.close();
    _orderStreamController = null;
  }

}

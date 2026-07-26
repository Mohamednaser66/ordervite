import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/config/app_config.dart';
import 'package:flutter_maps/core/map_utils.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/services/api.dart';
import 'package:flutter_maps/services/realtime_service.dart';
import 'package:flutter_maps/services/shipper_order_repository.dart';
import 'package:flutter_maps/shipper/models/ShipperOrdersList.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

part 'shipper_order_state.dart';

class ShipperOrderCubit extends Cubit<ShipperOrderState> {
  final RealtimeService _realtimeService = RealtimeService();

  StreamSubscription<Map<String, dynamic>?>? _orderStreamSubscription;
  String? _previousOrderState;
final ShipperOrderRepository repository = ShipperOrderRepository();
  ShipperOrderCubit() : super(ShipperOrderInitial());

  Future<void> fetchRoute(
      LatLng source,
      LatLng destination,
      String apiKey,
      String routeId,
      ) async {
    if (isClosed) return;

    emit(ShipperOrderLoading());

    try {
      final route = await repository.getRoute(
        source,
        destination,
        apiKey,
      );

      final points = decodePolyline(route.encodedPoints);

      if (!isClosed) {
        emit(
          ShipperOrderRouteLoaded(
            polylinePoints: points,
            distance: route.distance,
            routeId: routeId,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(ShipperOrderError(e.toString()));
      }
    }
  }

  void listenToCurrentOrder(String shipperId, String token) {
    _orderStreamSubscription?.cancel();

    _orderStreamSubscription = _realtimeService
        .getShipperCurrentOrderStream(shipperId: shipperId)
        .listen(
          (orderData) {
            if (isClosed) return;

            emit(ShipperOrderCurrentLoaded(orderData));

            if (orderData != null) {
              final currentState = orderData['order_state']?.toString() ?? '';
              if (currentState.isNotEmpty &&
                  currentState != _previousOrderState) {
                _previousOrderState = currentState;
                emit(ShipperOrderStatusChanged(orderData));
              }
            }
          },
          onError: (error) {
            if (!isClosed) {
              emit(ShipperOrderError(error.toString()));
            }
          },
        );
  }

  void stopListeningToOrder() {
    _orderStreamSubscription?.cancel();
    _orderStreamSubscription = null;
  }

  Future<bool> confirmOrder({
    required String orderId,
    required String shipperId,
    required String token,
    required double latitude,
    required double longitude,
  }) async {
    emit(ShipperOrderLoading());

    try {
      final id = int.parse(orderId);
      final url = "${AppConfig.baseUrl}/shippier/orders/$id";

      final response = await http
          .put(
            Uri.parse(url),
            body: {
              "shippier_id": shipperId,
              "sh_longitude": longitude.toString(),
              "sh_latitude": latitude.toString(),
              "order_state": "shipper confirmed",
            },
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        emit(ShipperOrderError("Failed to confirm order."));
        return false;
      }

      final responseBody = jsonDecode(response.body);

      // Fetch supplier api_token for notifications
      final supplierId = responseBody["data"]?["supplier_id"]?.toString();
      if (supplierId != null && supplierId.isNotEmpty) {
        await _fetchSupplierApiToken(supplierId, token);
      }

      emit(ShipperOrderCurrentLoaded(responseBody["data"]));
      return true;
    } catch (e) {
      emit(ShipperOrderError(_mapError(e)));
      return false;
    }
  }

  Future<bool> updateOrderPrice({
    required String orderId,
    required String token,
    required String price,
  }) async {
    emit(ShipperOrderLoading());

    try {
      final id = int.parse(orderId);
      final url = "${AppConfig.baseUrl}/shippier/order_update/$id";

      final response = await http
          .put(
            Uri.parse(url),
            body: {"price": price},
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        emit(ShipperOrderError("Failed to update order price."));
        return false;
      }

      final data = jsonDecode(response.body);
      emit(ShipperOrderCurrentLoaded(data["data"]));
      return true;
    } catch (e) {
      emit(ShipperOrderError(_mapError(e)));
      return false;
    }
  }

  /// Mark order as received.
  Future<bool> receiveOrder({
    required String orderId,
    required String token,
  }) async {
    emit(ShipperOrderLoading());

    try {
      final id = int.parse(orderId);
      final url = "${AppConfig.baseUrl}/shippier/order_update/$id";

      final response = await http
          .put(
            Uri.parse(url),
            body: {"order_state": "order received"},
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        emit(ShipperOrderError("Failed to update order."));
        return false;
      }

      final data = jsonDecode(response.body);
      emit(ShipperOrderCurrentLoaded(data["data"]));
      return true;
    } catch (e) {
      emit(ShipperOrderError(_mapError(e)));
      return false;
    }
  }

  /// Mark order as delivered.
  Future<bool> deliverOrder({
    required String orderId,
    required String token,
    required String supplierApiToken,
    required Lang lang,
  }) async {
    emit(ShipperOrderLoading());

    try {
      final id = int.parse(orderId);
      final url = "${AppConfig.baseUrl}/shippier/order_update/$id";

      final response = await http
          .put(
            Uri.parse(url),
            body: {"order_state": "order delivered"},
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        emit(ShipperOrderError("Failed to update order."));
        return false;
      }

      final reposnsebody = jsonDecode(response.body);

      // Notify supplier
      if (supplierApiToken.isNotEmpty) {
        final text = lang.lang == "en"
            ? "your order is delveried by shipper"
            : "تم تسليم الشحنة بواسطة مسئول الشحن  ";

        final notifyUrl =
            "${AppConfig.baseUrl}/notify/page/ordervite/$text/$supplierApiToken/1/ordervite/shipper/order delivered";

        await http
            .get(
              Uri.parse(notifyUrl),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 10));
      }

      emit(ShipperOrderCurrentLoaded(reposnsebody["data"]));
      return true;
    } catch (e) {
      emit(ShipperOrderError(_mapError(e)));
      return false;
    }
  }

  Future<bool> cancelOrder({
    required String orderId,
    required String shipperId,
    required String username,
    required String token,
    required String supplierApiToken,
    required Lang lang,
  }) async {
    emit(ShipperOrderLoading());

    try {
      final id = int.parse(orderId);
      final url = "${AppConfig.baseUrl}/shippier/order_update/$id";
      final name = "$shipperId shipper $username";

      final response = await http
          .put(
            Uri.parse(url),
            body: {"order_cancel": "$name cancel order"},
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        emit(ShipperOrderError("Failed to cancel order."));
        return false;
      }

      final reposnsebody = jsonDecode(response.body);

      if (supplierApiToken.isNotEmpty) {
        final text = lang.lang == "en"
            ? "your order is canceled by shipper"
            : " تم  الغاء الطلب بواسطة مسئول الشحن  ";

        final notifyUrl =
            "${AppConfig.baseUrl}/notify/page/ordervite/$text/$supplierApiToken/1/ordervite/shipper/order cancel";

        await http
            .get(
              Uri.parse(notifyUrl),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 10));
      }

      emit(ShipperOrderCancelled());
      return true;
    } catch (e) {
      emit(ShipperOrderError(_mapError(e)));
      return false;
    }
  }

  Future<String?> _fetchSupplierApiToken(
    String supplierId,
    String token,
  ) async {
    try {
      final id = int.parse(supplierId);
      final url = "${AppConfig.baseUrl}/shippier/supplier/$id";

      final response = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body);
      return json['data']?['name']?['api_token']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> updateFcmToken(
    String shipperId,
    String fcmToken,
    String token,
  ) async {
    try {
      final id = int.parse(shipperId);
      final url = "${AppConfig.baseUrl}/shippier/complete_profile/$id";

      await http
          .put(
            Uri.parse(url),
            body: {"api_token": fcmToken},
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  Future<void> getUnreadMessageCount(String orderId, String token) async {
    try {
      final id = int.parse(orderId);
      final url =
          "${AppConfig.baseUrl}/shippier/order/$id/messages/unread/supplier";

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return;

      final json = jsonDecode(response.body);
      final count = json['data']?['order unread messages count'] ?? 0;

      if (!isClosed) {
        emit(ShipperOrderMessageCountUpdated(count));
      }
    } catch (_) {}
  }

  Future<String?> handleOrderStateMessage(
    Map<String, dynamic> data,
    String token,
  ) async {
    final stateName = data["state_name"]?.toString();
    if (stateName == null) return null;

    if (stateName == "new message") {
      final orderId = data["order_id"]?.toString() ?? '';
      if (orderId.isNotEmpty) {
        await getUnreadMessageCount(orderId, token);
      }
    }

    return stateName;
  }

  String _mapError(Object e) {
    return e.toString();
  }

  Future<void> refreshCurrentOrder(String shipperId, String token) async {
    try {
      final orderData = await _realtimeService.getShipperCurrentOrder(
        shipperId: shipperId,
      );
      if (isClosed) return;

      if (orderData != null) {
        emit(ShipperOrderCurrentLoaded(orderData));

        final currentState = orderData['order_state']?.toString() ?? '';
        if (currentState.isNotEmpty && currentState != _previousOrderState) {
          _previousOrderState = currentState;
          emit(ShipperOrderStatusChanged(orderData));
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(ShipperOrderError(_mapError(e)));
      }
    }
  }

  @override
  Future<void> close() {
    _orderStreamSubscription?.cancel();
    return super.close();
  }
  Future<void> getShipperOrdersList(String shipperId) async {
    emit(SupplierOrderListLoading());

    try {
      final result = await Api().fetchShipperOrderList(shipperId);

      if (result != null) {
        emit(ShipperOrderListSuccess(result));
      } else {
        emit(ShipperOrderListError("No Data"));
      }
    } catch (e) {
      emit(ShipperOrderListError(e.toString()));
    }
  }

}

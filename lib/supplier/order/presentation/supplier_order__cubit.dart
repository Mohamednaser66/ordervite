import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/config/app_config.dart';
import 'package:flutter_maps/core/map_utils.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/models/order.dart';
import 'package:flutter_maps/services/api.dart';
import 'package:flutter_maps/services/order_repository.dart';
import 'package:flutter_maps/supplier/models/SuOrdersList.dart';
import 'package:flutter_maps/supplier/models/finance_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

part 'supplier_order__state.dart';

class SupplierOrderCubit extends Cubit<SupplierOrderState> {
  final OrderRepository _orderRepository;
  Timer? _autoCancelTimer;
  bool _timerStarted = false;
  String? _previousOrderState;
  StreamSubscription<Order?>? _orderStreamSubscription;
  SupplierOrderCubit(this._orderRepository) : super(SupplierOrderInitial());

  Future<void> fetchRoute(
    LatLng source,
    LatLng destination,
    String apiKey,
  ) async {
    emit(SupplierOrderLoading());

    try {
      final routeData = await _orderRepository.getRoute(
        source,
        destination,
        apiKey,
      );


      if (isClosed) return;

      if (routeData == null) {
        emit(SupplierOrderError("Could not calculate route."));
        return;
      }

      final points = decodePolyline(routeData['encodedPoints']);
      final distance = routeData['distance'];
      if (isClosed) return;

      emit(
        SupplierOrderRouteLoaded(polylinePoints: points, distance: distance),
      );
    } catch (e,s) {
      if (isClosed) return;
      emit(SupplierOrderError(_mapError(e)));
    }
  }

  Future<void> calculateEstimatedCost({
    required String token,
    required String size,
    required String paymentMethod,
  }) async {
    emit(SupplierOrderLoading());

    try {
      final financeConfig = await _orderRepository.getFinanceConfig(token);

      if (financeConfig == null) {
        emit(SupplierOrderError("Could not fetch finance config."));
        return;
      }

      final estimatedCost = financeConfig.calculateCost(
        size: size,
        paymentMethod: paymentMethod,
      );

      emit(
        SupplierOrderFinanceLoaded(
          financeConfig: financeConfig,
          estimatedCost: estimatedCost,
        ),
      );
    } catch (e) {
      emit(SupplierOrderError(_mapError(e)));
    }
  }

  Future<void> createOrder({
    required String token,
    required String supplierId,
    required String size,
    required String price,
    required String priceCheck,
    required LatLng source,
    required LatLng destination,
    required String distance,
    required String destinationAddress,
    String? sourceAddress,
    String? orderNote,
    double? preCalculatedCost,
  }) async {
    emit(SupplierOrderLoading());

    try {


      final financeConfig = await _orderRepository.getFinanceConfig(token);


      if (financeConfig == null) {
        debugPrint("Finance Config is NULL");
        emit(SupplierOrderError("Could not fetch finance config."));
        return;
      }

      final calculatedCost =
          preCalculatedCost ??
              financeConfig.calculateCost(
                size: size,
                paymentMethod: priceCheck,
              );

      debugPrint("Calculated Cost = $calculatedCost");

      final orderData = _buildOrderData(
        supplierId: supplierId,
        destinationAddress: destinationAddress,
        sourceAddress: sourceAddress,
        calculatedCost: calculatedCost,
        size: size,
        price: price,
        priceCheck: priceCheck,
        source: source,
        destination: destination,
        distance: distance,
        financeConfig: financeConfig,
        orderNote: orderNote,
      );



      final order = await _orderRepository.createOrder(orderData, token);

      debugPrint("Order Response = $order");

      if (order != null) {
        emit(SupplierOrderCreated(order));
      } else {
        emit(SupplierOrderError("Failed to create order."));
      }
    } catch (e, s) {

      emit(SupplierOrderError(_mapError(e)));
    }
  }

  Map<String, dynamic> _buildOrderData({
    required String supplierId,
    required double calculatedCost,
    required String size,
    required String price,
    required String priceCheck,
    required LatLng source,
    required LatLng destination,
    required String distance,
    required FinanceConfig financeConfig,
    String? orderNote,
    required String destinationAddress,
    String? sourceAddress,
  }) {
    final commission = financeConfig.calculateCommission(calculatedCost);
    final shipperPay = calculatedCost - commission;

    return {
      "supplier_id": supplierId,
      "cost": calculatedCost.toString(),
      "size": size,
      "price": price,
      "order_state": "new",
      "destination_address":destinationAddress,
      "source_address":sourceAddress,
      "pricecheck": priceCheck,
      "so_longitude": source.longitude.toString(),
      "so_latitude": source.latitude.toString(),
      "dist_longitude": destination.longitude.toString(),
      "dist_latitude": destination.latitude.toString(),
      "distance": distance,
      if (orderNote != null && orderNote.isNotEmpty) 'order_note': orderNote,
      'percentage': financeConfig.percentage.toString(),
      'shipper_pay': shipperPay.toStringAsFixed(2),
      'commission': commission.toStringAsFixed(2),
    };
  }

  void listenToCurrentOrder(String supplierId, String token) {
    _orderStreamSubscription?.cancel();

    _orderStreamSubscription = _orderRepository
        .getOrderStream(supplierId, token)
        .listen(
          (order) {
            if (isClosed) return;
            emit(SupplierOrderCurrentLoaded(order));

            if (order != null &&
                order.state.isNotEmpty &&
                order.state != _previousOrderState) {
              _previousOrderState = order.state;
              emit(SupplierOrderStatusChanged(order));
            }
          },
          onError: (error) {
            if (!isClosed) {
              emit(SupplierOrderError(error.toString()));
            }
          },
        );
  }

  void stopListeningToOrder() {
    _orderStreamSubscription?.cancel();
    _orderStreamSubscription = null;
  }

  void startAutoCancelTimer({
    required String orderId,
    required String supplierId,
    required String username,
    required String token,
    required String shipperApiToken,
    required Lang lang,
  }) {
    if (_timerStarted) return;
    _timerStarted = true;

    _autoCancelTimer?.cancel();
    _autoCancelTimer = Timer(AppConfig.autoCancelDuration, () async {
      try {
        await cancelOrder(
          orderId: orderId,
          supplierId: supplierId,
          username: username,
          token: token,
          shipperApiToken: shipperApiToken,
          lang: lang,
        );
      } catch (_) {}
    });
  }

  void stopAutoCancelTimer() {
    _autoCancelTimer?.cancel();
    _autoCancelTimer = null;
    _timerStarted = false;
  }

  Future<void> cancelOrder({
    required String orderId,
    required String supplierId,
    required String username,
    required String token,
    required String shipperApiToken,
    required Lang lang,
  }) async {
    emit(SupplierOrderLoading());

    try {
      final cancelMessage = "$supplierId supplier $username cancel order";

      await _orderRepository.cancelOrder(orderId, cancelMessage, token);

      if (shipperApiToken.isNotEmpty) {
        final text = lang.lang == "en"
            ? "your order is cancled by supplier!"
            : "تم إلغاء الطلب بواسطة المورد";

        await _orderRepository.notifyOrderCancellation(
          text,
          shipperApiToken,
          token,
        );
      }

      stopAutoCancelTimer();
      emit(SupplierOrderCancelled());
    } catch (e) {
      emit(SupplierOrderError("Failed to cancel order: ${_mapError(e)}"));
    }
  }

  Future<void> completeOrder({
    required String orderId,
    required String token,
    required String shipperApiToken,
    required Lang lang,
  }) async {
    if (isClosed) return;
    emit(SupplierOrderLoading());

    try {
      final success = await _orderRepository.updateOrderState(
        orderId,
        "order complete",
        token,
      );

      if (isClosed) return;

      if (!success) {
        emit(SupplierOrderError("Failed to complete order"));
        return;
      }
      if (!isClosed) {
        emit(
          SupplierOrderCompleted(
            orderId: orderId,
            shipperApiToken: shipperApiToken,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(SupplierOrderError(e.toString()));
      }
    }
  }

  Future<void> updateFcmToken(
    String supplierId,
    String fcmToken,
    String token,
  ) async {
    try {
      await _orderRepository.updateFcmToken(supplierId, fcmToken, token);
    } catch (_) {}
  }

  Future<void> getUnreadMessageCount(String orderId, String token) async {
    try {
      final count = await _orderRepository.getUnreadMessagesCount(
        orderId,
        token,
      );
      if (!isClosed) {
        emit(SupplierOrderMessageCountUpdated(count));
      }
    } catch (_) {}
  }

  Future<String?> handleOrderStateMessage(
    Map<String, dynamic> data,
    String token,
  ) async {
    final stateName = data["state_name"]?.toString();
    if (stateName == null) return null;

    if (stateName == "shipper confirmed") {
      final shipperId = data["state_type"]?.toString() ?? '';
      if (shipperId.isNotEmpty) {
        await _orderRepository.getShipperApiToken(shipperId, token);
        return shipperId;
      }
    }

    if (stateName == "new message") {
      final orderId = data["order_id"]?.toString() ?? '';
      if (orderId.isNotEmpty) {
        await getUnreadMessageCount(orderId, token);
      }
    }

    return null;
  }

  String _mapError(Object e) {
    return e.toString();
  }

  Future<void> refreshCurrentOrder(String supplierId, String token) async {
    try {
      final order = await _orderRepository.getOrder(supplierId, token);
      if (isClosed) return;

      if (order != null) {
        emit(SupplierOrderCurrentLoaded(order));

        if (order.state.isNotEmpty && order.state != _previousOrderState) {
          _previousOrderState = order.state;
          emit(SupplierOrderStatusChanged(order));
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(SupplierOrderError(_mapError(e)));
      }
    }
  }

  @override
  Future<void> close() {
    _autoCancelTimer?.cancel();
    _orderStreamSubscription?.cancel();
    return super.close();
  }
  Future<void> getUserOrderList(String supplierId) async {
    emit(SupplierOrderListLoading());

    try {
      final result = await Api().fetchUserOrderList(supplierId);

      if (result != null) {
        emit(SupplierOrderListSuccess(result));
      } else {
        emit(SupplierOrderListError("No Data"));
      }
    } catch (e) {
      emit(SupplierOrderListError(e.toString()));
    }
  }
}

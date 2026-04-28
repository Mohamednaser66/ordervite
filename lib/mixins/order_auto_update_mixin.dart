import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_maps/blocs/order_cubit.dart';
import 'package:flutter_maps/models/order.dart';

/// Mixin that provides automatic order status update functionality
/// Use this in any StatefulWidget that needs to react to order changes
mixin OrderAutoUpdateMixin<T extends StatefulWidget> on State<T> {
  OrderCubit? orderCubit;
  StreamSubscription<OrderState>? _orderSubscription;
  String? _previousOrderState;

  /// Initialize order listening in initState
  void initializeOrderListening(
    OrderCubit cubit,
    String supplierId,
    String token,
  ) {
    orderCubit = cubit;
    cubit.listenToOrder(supplierId, token);

    _orderSubscription = cubit.stream.listen((state) {
      if (!mounted) return;

      if (state is OrderLoaded) {
        final newState = state.order.state;
        // Only call handler if state actually changed
        if (newState != _previousOrderState) {
          _previousOrderState = newState;
          onOrderStatusChanged(state.order);
        }
      } else if (state is OrderError) {
        onOrderError(state.error);
      }
    });
  }

  /// Called when order status changes
  /// Override this method in your State class to handle status changes
  void onOrderStatusChanged(Order order) {}

  /// Called when an error occurs during order updates
  void onOrderError(String error) {}

  /// Clean up subscription
  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }
}

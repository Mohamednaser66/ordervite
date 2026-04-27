part of 'shipper_order_cubit.dart';

@immutable
sealed class ShipperOrderState {}

final class ShipperOrderInitial extends ShipperOrderState {}

final class ShipperOrderLoading extends ShipperOrderState {}

final class ShipperOrderRouteLoaded extends ShipperOrderState {
  final List<LatLng> polylinePoints;
  final String distance;

  ShipperOrderRouteLoaded({
    required this.polylinePoints,
    required this.distance,
  });
}

/// Emitted when the current order is fetched or updated via stream.
final class ShipperOrderCurrentLoaded extends ShipperOrderState {
  final Map<String, dynamic>? orderData;

  ShipperOrderCurrentLoaded(this.orderData);
}

/// Emitted when the order status string changes (e.g. "new" → "shipper confirmed").
final class ShipperOrderStatusChanged extends ShipperOrderState {
  final Map<String, dynamic> orderData;

  ShipperOrderStatusChanged(this.orderData);
}

/// Emitted when unread chat message count changes.
final class ShipperOrderMessageCountUpdated extends ShipperOrderState {
  final int count;

  ShipperOrderMessageCountUpdated(this.count);
}

final class ShipperOrderCancelled extends ShipperOrderState {}

final class ShipperOrderCompleted extends ShipperOrderState {}

final class ShipperOrderError extends ShipperOrderState {
  final String message;

  ShipperOrderError(this.message);
}

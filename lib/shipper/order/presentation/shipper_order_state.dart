part of 'shipper_order_cubit.dart';

@immutable
sealed class ShipperOrderState {}

final class ShipperOrderInitial extends ShipperOrderState {}

final class ShipperOrderLoading extends ShipperOrderState {}

final class ShipperOrderRouteLoaded extends ShipperOrderState {
  final List<LatLng> polylinePoints;
  final String distance;
  final String routeId;

   ShipperOrderRouteLoaded({
    required this.polylinePoints,
    required this.distance,
    required this.routeId,
  });
}

final class ShipperOrderCurrentLoaded extends ShipperOrderState {
  final Map<String, dynamic>? orderData;

  ShipperOrderCurrentLoaded(this.orderData);
}

final class ShipperOrderStatusChanged extends ShipperOrderState {
  final Map<String, dynamic> orderData;

  ShipperOrderStatusChanged(this.orderData);
}

final class ShipperOrderMessageCountUpdated extends ShipperOrderState {
  final int count;

  ShipperOrderMessageCountUpdated(this.count);
}

final class ShipperOrderCancelled extends ShipperOrderState {}

final class ShipperOrderCompleted extends ShipperOrderState {}

final class ShipperOrderError extends ShipperOrderState {
  final String message;

  ShipperOrderError(this.message);
}class SupplierOrderListLoading extends ShipperOrderState {}

class ShipperOrderListSuccess extends ShipperOrderState {
  final ShipperOrdersList orders;

  ShipperOrderListSuccess(this.orders);
}

class ShipperOrderListError extends ShipperOrderState {
  final String message;

  ShipperOrderListError(this.message);
}

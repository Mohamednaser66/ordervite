part of 'supplier_order__cubit.dart';

@immutable
sealed class SupplierOrderState {}

final class SupplierOrderInitial extends SupplierOrderState {}

final class SupplierOrderLoading extends SupplierOrderState {}

final class SupplierOrderRouteLoaded extends SupplierOrderState {
  final List<LatLng> polylinePoints;
  final String distance;

  SupplierOrderRouteLoaded({
    required this.polylinePoints,
    required this.distance,
  });
}

final class SupplierOrderFinanceLoaded extends SupplierOrderState {
  final FinanceConfig financeConfig;
  final double estimatedCost;

  SupplierOrderFinanceLoaded({
    required this.financeConfig,
    required this.estimatedCost,
  });
}

final class SupplierOrderCreated extends SupplierOrderState {
  final Order order;

  SupplierOrderCreated(this.order);
}

/// Emitted when the current (already existing) order is fetched or updated.
final class SupplierOrderCurrentLoaded extends SupplierOrderState {
  final Order? order;

  SupplierOrderCurrentLoaded(this.order);
}

/// Emitted when the order status string changes (e.g. "new" → "shipper confirmed").
final class SupplierOrderStatusChanged extends SupplierOrderState {
  final Order order;

  SupplierOrderStatusChanged(this.order);
}

/// Emitted when unread chat message count changes.
final class SupplierOrderMessageCountUpdated extends SupplierOrderState {
  final int count;

  SupplierOrderMessageCountUpdated(this.count);
}

final class SupplierOrderCancelled extends SupplierOrderState {}

final class SupplierOrderCompleted extends SupplierOrderState {
  final String orderId;
  final String shipperApiToken;

  SupplierOrderCompleted({
    required this.orderId,
    required this.shipperApiToken,
  });
}

final class SupplierOrderError extends SupplierOrderState {
  final String message;

  SupplierOrderError(this.message);
}
class SupplierOrderListLoading extends SupplierOrderState {}

class SupplierOrderListSuccess extends SupplierOrderState {
  final SuOrdersList orders;

  SupplierOrderListSuccess(this.orders);
}

class SupplierOrderListError extends SupplierOrderState {
  final String message;

  SupplierOrderListError(this.message);
}

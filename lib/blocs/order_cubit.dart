import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/models/order.dart';
import 'package:flutter_maps/services/order_repository.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final Order order;
  OrderLoaded(this.order);
}

class OrderError extends OrderState {
  final String error;
  OrderError(this.error);
}

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository repository;
  StreamSubscription? _orderStreamSubscription;

  OrderCubit(this.repository) : super(OrderInitial());

  void listenToOrder(String supplierId, String token) {
    _orderStreamSubscription?.cancel();

    _orderStreamSubscription = repository
        .watchOrder(supplierId, token)
        .listen(
          (order) {
            if (!isClosed) {
              emit(OrderLoaded(order));
            }
          },
          onError: (error) {
            if (!isClosed) {
              emit(OrderError(error.toString()));
            }
          },
        );
  }

  @override
  Future<void> close() {
    _orderStreamSubscription?.cancel();
    return super.close();
  }
}

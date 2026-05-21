part of 'supplier_home_cubit.dart';

@immutable
sealed class SupplierHomeState {}

final class SupplierHomeInitial extends SupplierHomeState {}
final class SupplierHomeSuccess extends SupplierHomeState {
  List<ShippersData>? shippers;
  SupplierHomeSuccess({required this.shippers});
}
final class SupplierHomeLoading extends SupplierHomeState {}
final class SupplierHomeError extends SupplierHomeState {
  String? message;
  SupplierHomeError({required this.message});
}

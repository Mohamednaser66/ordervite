part of 'supplier_profile_cubit.dart';

@immutable
sealed class SupplierProfileState {}

final class SupplierProfileInitial extends SupplierProfileState {}
final class DeleteSupplierSuccess extends SupplierProfileState {}
final class DeleteSupplierError extends SupplierProfileState {
  String? error;
  DeleteSupplierError({required this.error});
}
final class DeleteSupplierLoading extends SupplierProfileState {}


part of 'shipper_profile_cubit.dart';

@immutable
sealed class ShipperProfileState {}

final class ShipperProfileInitial extends ShipperProfileState {}
final class DeleteShipperSuccess extends ShipperProfileState {}
final class DeleteShipperError extends ShipperProfileState {
  String? error;
  DeleteShipperError({required this.error});
}
final class DeleteShipperLoading extends ShipperProfileState {}

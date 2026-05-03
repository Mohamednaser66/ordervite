import 'package:bloc/bloc.dart';
import 'package:flutter_maps/services/api.dart';
import 'package:meta/meta.dart';

part 'shipper_profile_state.dart';
class ShipperProfileCubit extends Cubit<ShipperProfileState> {
  final Api api;

  ShipperProfileCubit({required this.api}) : super(ShipperProfileInitial());

  Future<void> deleteShipperAccount(String token) async {
    emit(DeleteShipperLoading());

    try {

      final result = await api.deleteShipper(token);

      if (result) {
        emit(DeleteShipperSuccess());
      } else {
        emit(DeleteShipperError(error: 'Failed to delete account'));
      }
    } catch (e) {
      emit(DeleteShipperError(error: e.toString()));
    }
  }
}
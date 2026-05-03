import 'package:bloc/bloc.dart';
import 'package:flutter_maps/services/api.dart';
import 'package:meta/meta.dart';

part 'supplier_profile_state.dart';
class SupplierProfileCubit extends Cubit<SupplierProfileState> {
  final Api api;

  SupplierProfileCubit({required this.api}) : super(SupplierProfileInitial());

  Future<void> deleteSupplierAccount(String token) async {
    emit(DeleteSupplierLoading());

    try {

      final result = await api.deleteSupplier(token);

      if (result) {
        emit(DeleteSupplierSuccess());
      } else {
        emit(DeleteSupplierError(error: 'Failed to delete account'));
      }
    } catch (e) {
      emit(DeleteSupplierError(error: e.toString()));
    }
  }
}
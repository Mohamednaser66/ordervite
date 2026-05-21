import 'package:bloc/bloc.dart';
import 'package:flutter_maps/supplier/home_page/data/models/ShippersData.dart';
import 'package:flutter_maps/supplier/home_page/domin/use_case.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

part 'supplier_home_state.dart';
@injectable
class SupplierHomeCubit extends Cubit<SupplierHomeState> {
  @factoryMethod
  SupplierHomeCubit(this._useCase) : super(SupplierHomeInitial());
  SupplierHomeUseCase _useCase;
  getShippers(String token)async{
    emit(SupplierHomeLoading());
   var result=await _useCase.invoke(token);
   result.fold((l) {
     emit(SupplierHomeError(message: l.message));
   }, (r) {
     emit(SupplierHomeSuccess(shippers: r.data));
   },);
  }
}

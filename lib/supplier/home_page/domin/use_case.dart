import 'package:dartz/dartz.dart';
import 'package:flutter_maps/core/error/failure.dart';
import 'package:flutter_maps/supplier/home_page/data/models/ShippersData.dart';
import 'package:flutter_maps/supplier/home_page/domin/repository.dart';
import 'package:injectable/injectable.dart';
@injectable
class SupplierHomeUseCase {
  SupplierHomeRepository _repository;
  @factoryMethod
  SupplierHomeUseCase(this._repository);
  Future<Either<Failure,ShippersData>> invoke(String token)async{
   return await _repository.getShippers(token);
  }
}
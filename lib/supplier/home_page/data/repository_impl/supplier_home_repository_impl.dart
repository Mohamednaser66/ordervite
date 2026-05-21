import 'package:dartz/dartz.dart';
import 'package:flutter_maps/core/error/exception.dart';
import 'package:flutter_maps/core/error/failure.dart';
import 'package:flutter_maps/supplier/home_page/data/data_source/supplier_home_data_source.dart';
import 'package:flutter_maps/supplier/home_page/data/models/ShippersData.dart';
import 'package:flutter_maps/supplier/home_page/domin/repository.dart';
import 'package:injectable/injectable.dart';
@Injectable(as: SupplierHomeRepository)
class SupplierHomeRepositoryImpl implements SupplierHomeRepository{
 final SupplierHomeDataSource _dataSource;
  @factoryMethod
  SupplierHomeRepositoryImpl(this._dataSource);
  @override
  Future<Either<Failure, ShippersData>> getShippers(String token) async{
    try{
    var  response=await _dataSource.getShippers(token);
    return Right(response.data!);
    }on AppException catch(exception){
      return Left(Failure(exception.message));
    }


  }

}
import 'package:dio/dio.dart';
import 'package:flutter_maps/core/constant_manager.dart';
import 'package:flutter_maps/core/error/exception.dart';
import 'package:flutter_maps/supplier/home_page/data/data_source/supplier_home_data_source.dart';
import 'package:flutter_maps/supplier/home_page/data/models/GetShippersModel.dart';
import 'package:injectable/injectable.dart';
@Injectable(as:SupplierHomeDataSource )
class SupplierHomeDataSourceImpl implements SupplierHomeDataSource{
 final Dio _dio =Dio(BaseOptions(baseUrl:ConstantManager.baseUrl ));
  @override
  getShippers(String token) async{
   try{
   var response =await  _dio.get(ConstantManager.getShippersEndpoint,options: Options( headers: {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
    }, ));
   return GetShippersModel.fromJson(response.data);
   }on DioException catch(exception){

    throw RemoteException(exception.response?.data['message']);
   }
  }
}
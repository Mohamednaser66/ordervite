import 'package:flutter_maps/supplier/home_page/data/models/GetShippersModel.dart';

abstract class SupplierHomeDataSource {
 Future<GetShippersModel> getShippers(String token);
}
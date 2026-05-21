import 'package:dartz/dartz.dart';
import 'package:flutter_maps/core/error/failure.dart';
import 'package:flutter_maps/supplier/home_page/data/models/ShippersData.dart';


abstract class SupplierHomeRepository {
 Future<Either<Failure,ShippersData>> getShippers(String token);
}
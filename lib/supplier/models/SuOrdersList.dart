import 'su_orders.dart';
class SuOrdersList {
  SuOrdersList({
      this.success, 
      this.data, 
      this.message,});

  SuOrdersList.fromJson(dynamic json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(suOrders.fromJson(v));
      });
    }
    message = json['message'];
  }
  bool? success;
  List<suOrders>? data;
  String? message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    map['message'] = message;
    return map;
  }

}
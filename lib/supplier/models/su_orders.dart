

class suOrders {
  suOrders({
      this.id, 
      this.supplierId, 
      this.shippierId, 
      this.cost, 
      this.type, 
      this.size, 
      this.distance, 
      this.price, 
      this.pricecheck, 
      this.review, 
      this.commission, 
      this.percentage, 
      this.shipperPay, 
      this.paymentStatus, 
      this.rating, 
      this.orderNote, 
      this.soLongitude, 
      this.soLatitude, 
      this.distLongitude, 
      this.distLatitude, 
      this.shLongitude, 
      this.shLatitude, 
      this.orderState, 
      this.orderCancel, 
      this.createdAt, 
      this.updatedAt,});

  suOrders.fromJson(dynamic json) {
    id = json['id'];
    supplierId = json['supplier_id'];
    shippierId = json['shippier_id'];
    cost = (json['cost'] as num?)?.toInt();
    type = json['type'];
    size = json['size'];
    distance = (json['distance'] as num?)?.toInt();
    price = json['price']?.toString();
    pricecheck = json['pricecheck']?.toString();
    review = json['review'];

    commission = (json['commission'] as num?)?.toDouble();
    percentage = (json['percentage'] as num?)?.toInt();
    shipperPay = (json['shipper_pay'] as num?)?.toDouble();

    paymentStatus = (json['payment_status'] as num?)?.toInt();
    rating = (json['rating'] as num?)?.toInt();

    orderNote = json['order_note'];

    soLongitude = (json['so_longitude'] as num?)?.toDouble();
    soLatitude = (json['so_latitude'] as num?)?.toDouble();
    distLongitude = (json['dist_longitude'] as num?)?.toDouble();
    distLatitude = (json['dist_latitude'] as num?)?.toDouble();

    shLongitude = (json['sh_longitude'] as num?)?.toDouble();
    shLatitude = (json['sh_latitude'] as num?)?.toDouble();

    orderState = json['order_state'];
    orderCancel = json['order_cancel'];

    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  int? id;
  int? supplierId;
  dynamic shippierId;
  num? cost;
  String? type;
  String? size;
  num? distance;
  String? price;
  String? pricecheck;
  dynamic review;
  double? commission;
  int? percentage;
  double? shipperPay;
  int? paymentStatus;
  int? rating;
  dynamic orderNote;
  double? soLongitude;
  double? soLatitude;
  double? distLongitude;
  double? distLatitude;
  dynamic shLongitude;
  dynamic shLatitude;
  String? orderState;
  dynamic orderCancel;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['supplier_id'] = supplierId;
    map['shippier_id'] = shippierId;
    map['cost'] = cost;
    map['type'] = type;
    map['size'] = size;
    map['distance'] = distance;
    map['price'] = price;
    map['pricecheck'] = pricecheck;
    map['review'] = review;
    map['commission'] = commission;
    map['percentage'] = percentage;
    map['shipper_pay'] = shipperPay;
    map['payment_status'] = paymentStatus;
    map['rating'] = rating;
    map['order_note'] = orderNote;
    map['so_longitude'] = soLongitude;
    map['so_latitude'] = soLatitude;
    map['dist_longitude'] = distLongitude;
    map['dist_latitude'] = distLatitude;
    map['sh_longitude'] = shLongitude;
    map['sh_latitude'] = shLatitude;
    map['order_state'] = orderState;
    map['order_cancel'] = orderCancel;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

}
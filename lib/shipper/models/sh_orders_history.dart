

class ShOrdersHistory {
  ShOrdersHistory({
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
      this.destinationAddress, 
      this.sourceAddress, 
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

  ShOrdersHistory.fromJson(dynamic json) {
    id = json['id'];
    supplierId = json['supplier_id'];
    shippierId = json['shippier_id'];
    cost = json['cost'];
    type = json['type'];
    size = json['size'];
    distance = json['distance'];
    price = json['price'];
    pricecheck = json['pricecheck'];
    review = json['review'];
    commission = json['commission'];
    percentage = json['percentage'];
    shipperPay = json['shipper_pay'];
    paymentStatus = json['payment_status'];
    rating = json['rating'];
    orderNote = json['order_note'];
    destinationAddress = json['destination_address'];
    sourceAddress = json['source_address'];
    soLongitude = json['so_longitude'];
    soLatitude = json['so_latitude'];
    distLongitude = json['dist_longitude'];
    distLatitude = json['dist_latitude'];
    shLongitude = json['sh_longitude'];
    shLatitude = json['sh_latitude'];
    orderState = json['order_state'];
    orderCancel = json['order_cancel'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  int? id;
  int? supplierId;
  int? shippierId;
  num? cost;
  String? type;
  String? size;
  num? distance;
  String? price;
  String? pricecheck;
  dynamic review;
  double? commission;
  num? percentage;
  num? shipperPay;
  num? paymentStatus;
  int? rating;
  dynamic orderNote;
  dynamic destinationAddress;
  dynamic sourceAddress;
  num? soLongitude;
  num? soLatitude;
  num? distLongitude;
  num? distLatitude;
  num? shLongitude;
  num? shLatitude;
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
    map['destination_address'] = destinationAddress;
    map['source_address'] = sourceAddress;
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
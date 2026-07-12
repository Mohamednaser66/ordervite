class OrderData {
  final String disLat;
  final String sorLat;
  final String disLong;
  final String sorlong;
  final String order_id;
  final bool isConfirm;
  final String order_cost;
  final String order_price;
  final String order_pricecheck;
  final String order_state;
  final String order_supplier_id;
  final String? orderNote;

  OrderData(
    this.disLat,
    this.sorLat,
    this.disLong,
    this.sorlong,
    this.order_id,
    this.isConfirm,
    this.order_cost,
    this.order_price,
    this.order_pricecheck,
    this.order_state,
    this.order_supplier_id, {
    this.orderNote,
  });
}

class OrderDist {
  final String disLat;
  final String sorLat;
  final String disLong;
  final String sorlong;

  final bool isConfirm;

  final String? order_id;
  final String? order_cost;
  final String? order_price;
  final String? order_pricecheck;
  final String? order_state;
  final String? order_shippier_id;
  final String? orderNote;
  final String? orderType;

  OrderDist(
    this.disLat,
    this.sorLat,
    this.disLong,
    this.sorlong,
    this.isConfirm,
    this.order_id,
    this.order_cost,
    this.order_price,
    this.order_pricecheck,
    this.order_state,
    this.order_shippier_id, {
    this.orderNote,
    this.orderType,
  });
}

class Message {
  final String message;
  Message(this.message);
}

class OrderView {
  final String order_id;
  final String api_token;
  OrderView(this.order_id, this.api_token);
}

class Chat {
  final String conservistion_id;
  final String? supplier_id;
  final String? shippier_id;
  final String? supplier_name;
  final String? shippier_name;
  final String type;
  final String api_token;

  final String disLat;
  final String sorLat;
  final String disLong;
  final String sorlong;
  final bool isConfirm;

  final String order_cost;
  final String order_price;
  final String order_pricecheck;
  final String order_state;

  final String order_shippier_id;

  final String order_supplier_id;

  Chat(
    this.conservistion_id,
    this.supplier_id,
    this.shippier_id,
    this.supplier_name,
    this.shippier_name,
    this.type,
    this.api_token,
    this.disLat,
    this.sorLat,
    this.disLong,
    this.sorlong,
    this.isConfirm,
    this.order_cost,
    this.order_price,
    this.order_pricecheck,
    this.order_state,
    this.order_supplier_id,
    this.order_shippier_id,
  );
}

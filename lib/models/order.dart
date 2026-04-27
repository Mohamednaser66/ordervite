class Order {
  final String? id;
  final String state;
  final String shipperId;
  final String? cost;
  final String? price;
  final String? priceCheck;
  final dynamic orderCancel;

  Order({
    this.id,
    required this.state,
    required this.shipperId,
    this.cost,
    this.price,
    this.priceCheck,
    this.orderCancel,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString(),
      state: json['order_state']?.toString() ?? 'new',
      shipperId: json['shippier_id']?.toString() ?? '',
      cost: (json['order_cost'] ?? json['cost'])?.toString(),
      price: (json['order_price'] ?? json['price'])?.toString(),
      priceCheck: (json['order_pricecheck'] ?? json['pricecheck'])?.toString(),
      orderCancel: json['order_cancel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_state': state,
      'shippier_id': shipperId,
      'cost': cost,
      'price': price,
      'pricecheck': priceCheck,
      'order_cancel': orderCancel,
    };
  }
}

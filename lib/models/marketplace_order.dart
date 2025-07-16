class MarketplaceOrder {
  final int? id;
  final int buyerId;
  final int sellerId;
  final int productId;
  final int quantity;
  final double totalAmount;
  final String status;
  final String shippingDetails;
  final String orderDate;

  MarketplaceOrder({
    this.id,
    required this.buyerId,
    required this.sellerId,
    required this.productId,
    required this.quantity,
    required this.totalAmount,
    required this.status,
    required this.shippingDetails,
    required this.orderDate,
  });

  factory MarketplaceOrder.fromJson(Map<String, dynamic> json) {
    return MarketplaceOrder(
      id: json['id'],
      buyerId: json['buyerId'],
      sellerId: json['sellerId'],
      productId: json['productId'],
      quantity: json['quantity'],
      totalAmount: json['totalAmount'] is int ? json['totalAmount'].toDouble() : json['totalAmount'],
      status: json['status'],
      shippingDetails: json['shippingDetails'],
      orderDate: json['orderDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'productId': productId,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'status': status,
      'shippingDetails': shippingDetails,
      'orderDate': orderDate,
    };
  }
} 
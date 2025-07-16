class MarketplaceInquiry {
  final int? id;
  final String subject;
  final String message;
  final int senderId;
  final int recipientId;
  final int productId;
  final String status;

  MarketplaceInquiry({
    this.id,
    required this.subject,
    required this.message,
    required this.senderId,
    required this.recipientId,
    required this.productId,
    required this.status,
  });

  factory MarketplaceInquiry.fromJson(Map<String, dynamic> json) {
    return MarketplaceInquiry(
      id: json['id'],
      subject: json['subject'],
      message: json['message'],
      senderId: json['senderId'],
      recipientId: json['recipientId'],
      productId: json['productId'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'subject': subject,
      'message': message,
      'senderId': senderId,
      'recipientId': recipientId,
      'productId': productId,
      'status': status,
    };
  }
}
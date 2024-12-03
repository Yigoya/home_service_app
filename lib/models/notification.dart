class NotificationModel {
  final int id;
  final int recipientId;
  final String title;
  final String message;
  final String type;
  bool readStatus;
  final DateTime deliveryDate;
  final int relatedEntityId;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.message,
    required this.type,
    this.readStatus = false,
    required this.deliveryDate,
    required this.relatedEntityId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      recipientId: json['recipientId'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      readStatus: json['readStatus'],
      deliveryDate: DateTime.parse(json['deliveryDate']),
      relatedEntityId: json['relatedEntityId'],
    );
  }
}

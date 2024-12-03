class Dispute {
  final int id;
  final String personName;
  final String description;
  final String reason;
  final String status;
  final String createdAt;
  final String updatedAt;

  Dispute({
    required this.id,
    required this.personName,
    required this.description,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Dispute.fromJson(Map<String, dynamic> json) {
    return Dispute(
      id: json['id'],
      personName: json['personName'],
      description: json['description'],
      reason: json['reason'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personName': personName,
      'description': description,
      'reason': reason,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

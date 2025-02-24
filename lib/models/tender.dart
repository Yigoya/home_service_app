class Tender {
  final int id;
  final String title;
  final String? description;
  final String location;
  final String? closingDate;
  final String? questionDeadline;
  final String? contactInfo;
  final String status;
  final int serviceId;
  final String? document;
  final String categoryName;

  Tender({
    required this.id,
    required this.title,
    this.description,
    required this.location,
    this.closingDate,
    this.questionDeadline,
    required this.contactInfo,
    required this.status,
    required this.serviceId,
    this.document,
    required this.categoryName,
  });

  factory Tender.fromJson(Map<String, dynamic> json) {
    return Tender(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      closingDate: json['closingDate'],
      questionDeadline: json['questionDeadline'],
      contactInfo: json['contactInfo'],
      status: json['status'],
      serviceId: json['serviceId'],
      document: json['document'],
      categoryName: json['categoryName'],
    );
  }
}

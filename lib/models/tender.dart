class Tender {
  final int id;
  final String title;
  final String? description;
  final String location;
  final String? closingDate;
  final String? contactInfo;
  final String status;
  final int serviceId;
  final String? document;

  Tender({
    required this.id,
    required this.title,
    this.description,
    required this.location,
    this.closingDate,
    required this.contactInfo,
    required this.status,
    required this.serviceId,
    this.document,
  });

  factory Tender.fromJson(Map<String, dynamic> json) {
    return Tender(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      closingDate: json['closingDate'],
      contactInfo: json['contactInfo'],
      status: json['status'],
      serviceId: json['serviceId'],
      document: json['document'],
    );
  }
}

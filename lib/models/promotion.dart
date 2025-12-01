class Promotion {
  final int id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String type;
  final double? discountPercentage;
  final String businessName;
  final String? businessLogo;
  final int businessId;
  final String? businessCategory;
  final bool isActive;
  final bool isFeatured;
  final String? imageUrl;
  final String? termsAndConditions;
  final List<dynamic> services;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.type,
    this.discountPercentage,
    required this.businessName,
    this.businessLogo,
    required this.businessId,
    this.businessCategory,
    required this.isActive,
    required this.isFeatured,
    this.imageUrl,
    this.termsAndConditions,
    required this.services,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      type: json['type'] ?? '',
      discountPercentage: json['discountPercentage']?.toDouble(),
      businessName: json['businessName'] ?? '',
      businessLogo: json['businessLogo'],
      businessId: json['businessId'] ?? 0,
      businessCategory: json['businessCategory'],
      isActive: json['isActive'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      imageUrl: json['imageUrl'],
      termsAndConditions: json['termsAndConditions'],
      services: json['services'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'type': type,
      'discountPercentage': discountPercentage,
      'businessName': businessName,
      'businessLogo': businessLogo,
      'businessId': businessId,
      'businessCategory': businessCategory,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'imageUrl': imageUrl,
      'termsAndConditions': termsAndConditions,
      'services': services,
    };
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isActiveNow => isActive && !isExpired;

  String get formattedStartDate =>
      '${startDate.day}/${startDate.month}/${startDate.year}';
  String get formattedEndDate =>
      '${endDate.day}/${endDate.month}/${endDate.year}';

  String get validityPeriod => '$formattedStartDate - $formattedEndDate';
}

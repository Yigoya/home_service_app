import 'package:home_service_app/models/rating.dart';

class Booking {
  final int id;
  final String customerName;
  final String technicianName;
  final String? technicianProfileImage;
  final String? customerProfileImage;
  final String serviceName;
  final String scheduledDate;
  final String status;
  final String? description; // Added description attribute
  final Address address;
  final Review? review;

  Booking({
    required this.id,
    required this.customerName,
    required this.technicianName,
    required this.technicianProfileImage,
    this.customerProfileImage,
    required this.serviceName,
    required this.scheduledDate,
    required this.status,
    this.description, // Added description attribute
    required this.address,
    this.review,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      customerName: json['customerName'],
      technicianName: json['technicianName'],
      technicianProfileImage: json['technicianProfleImage'],
      customerProfileImage: json['customerProfleImage'],
      serviceName: json['serviceName'],
      scheduledDate: json['scheduledDate'] ?? '',
      status: json['status'],
      description: json['description'], // Added description attribute
      address: Address.fromJson(json['address']),
      review: json['review'] != null ? Review.fromJson(json['review']) : null,
    );
  }
}

class Address {
  final int? id;
  final int? customerId;
  final String? street;
  final String? city;
  final String? subcity;
  final String? wereda;
  final String? state;
  final String? country;
  final String? zipCode;
  final double? latitude;
  final double? longitude;

  Address({
    this.id,
    this.customerId,
    this.street,
    this.city,
    required this.subcity,
    required this.wereda,
    this.state,
    this.country,
    this.zipCode,
    this.latitude,
    this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      customerId: json['customerId'],
      street: json['street'],
      city: json['city'],
      subcity: json['subcity'],
      wereda: json['wereda'],
      state: json['state'],
      country: json['country'],
      zipCode: json['zipCode'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

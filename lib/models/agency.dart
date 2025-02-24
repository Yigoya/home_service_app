import 'package:home_service_app/models/service.dart';

class Agency {
  final int id;
  final String businessName;
  final String description;
  final String address;
  final String city;
  final String state;
  final String zip;
  final String country;
  final String phone;
  final String website;
  final String document;
  final List<Service>? services;
  final String image;

  Agency({
    required this.id,
    required this.businessName,
    required this.description,
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
    required this.phone,
    required this.website,
    required this.document,
    required this.services,
    required this.image,
  });

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      id: json['id'],
      businessName: json['businessName'],
      description: json['description'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zip: json['zip'],
      country: json['country'],
      phone: json['phone'],
      website: json['website'],
      document: json['document'],
      services: json['services'] != null
          ? (json['services'] as List)
              .map((service) => Service.fromJson(service))
              .toList()
          : null,
      image: json['image'],
    );
  }
}

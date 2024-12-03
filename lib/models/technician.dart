import 'package:home_service_app/models/service.dart';

class Technician {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String bio;
  final String? availability;
  final double? rating;
  final String profileImage;
  final int? completedJobs;
  final String? city;
  final String? subcity;
  final String? wereda;
  final String? country;
  final double? latitude;
  final double? longitude;
  final List<String> documents;
  final List<Service> services;

  Technician({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.bio,
    this.availability,
    this.rating,
    this.completedJobs,
    this.city,
    this.subcity,
    this.wereda,
    this.country,
    this.latitude,
    this.longitude,
    required this.documents,
    required this.profileImage,
    required this.services,
  });

  factory Technician.fromJson(Map<String, dynamic> json) {
    return Technician(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      bio: json['bio'] ?? '',
      availability: json['availability'],
      rating: json['rating'],
      completedJobs: json['completed_jobs'],
      city: json['city'],
      subcity: json['subcity'],
      wereda: json['wereda'],
      country: json['country'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      documents: List<String>.from(json['documents']),
      profileImage: json['profileImage'] ?? '',
      services: List<Service>.from(
        json['services'].map(
          (service) => Service.fromJson(service),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'bio': bio,
      'availability': availability,
      'rating': rating,
      'completed_jobs': completedJobs,
      'city': city,
      'subcity': subcity,
      'wereda': wereda,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'documents': documents,
      'profile_image': profileImage,
      'services': services.map((service) => service.toJson()).toList(),
    };
  }
}

import 'package:home_service_app/models/rating.dart';
import 'package:home_service_app/models/schedule.dart';
import 'package:home_service_app/models/service.dart';

class TechinicianDetail {
  final int id;
  final String name;
  final String email;
  final String? city;
  final String? subcity; // Added subcity field
  final String phoneNumber;
  final String profileImage;
  final String bio;
  final String role;
  final List<Service> services;
  final double rating;
  final int bookings;
  final Schedule? schedule;
  final List<Review> reviews;

  TechinicianDetail({
    required this.id,
    required this.name,
    required this.email,
    required this.city,
    required this.subcity, // Added subcity field
    required this.phoneNumber,
    required this.profileImage,
    required this.bio,
    required this.role,
    required this.services,
    required this.rating,
    required this.bookings,
    required this.schedule,
    required this.reviews,
  });

  factory TechinicianDetail.fromJson(Map<String, dynamic> json) {
    return TechinicianDetail(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      city: json['city'],
      subcity: json['subcity'], // Added subcity field
      phoneNumber: json['phoneNumber'],
      profileImage: json['profileImage'],
      bio: json['bio'],
      role: json['role'],
      services: (json['services'] as List)
          .map((service) => Service.fromJson(service))
          .toList(),
      rating: json['rating'],
      bookings: json['bookings'],
      schedule:
          json['schedule'] != null ? Schedule.fromJson(json['schedule']) : null,
      reviews: (json['review'] as List)
          .map((review) => Review.fromJson(review))
          .toList(),
    );
  }
}

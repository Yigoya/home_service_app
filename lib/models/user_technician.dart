import 'package:home_service_app/models/service.dart';

class UserTechnician {
  final int id;
  final String? bio;
  final double? rating;
  final double? completedJobs;
  final String? idCardImage;
  final List<String>? documents;
  final List<Service>? services;

  UserTechnician({
    required this.id,
    this.bio,
    this.rating,
    this.completedJobs,
    this.idCardImage,
    this.documents,
    this.services,
  });

  factory UserTechnician.fromJson(Map<String, dynamic> json) {
    var documentsFromJson = json['documents'];
    List<String> documentsList = List<String>.from(documentsFromJson);

    var servicesFromJson = json['services'] as List;
    List<Service> servicesList = servicesFromJson
        .map((serviceJson) => Service.fromJson(serviceJson))
        .toList();

    return UserTechnician(
      id: json['id'],
      bio: json['bio'],
      rating: json['rating'],
      completedJobs: json['completedJobs'],
      idCardImage: json['idCardImage'],
      documents: documentsList,
      services: servicesList,
    );
  }
}

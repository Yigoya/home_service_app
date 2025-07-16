import 'package:home_service_app/models/service.dart';

class Category {
  final int id;
  final String categoryName;
  final String? description;
  final String? icon;
  final List<Service> services;

  Category({
    required this.id,
    required this.categoryName,
    this.description,
    this.icon,
    required this.services,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['categoryId'],
      categoryName: json['categoryName'],
      description: json['description'],
      icon: json['icon'],
      services:
          json['services'].map<Service>((e) => Service.fromJson(e)).toList(),
    );
  }
}

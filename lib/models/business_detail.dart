import 'dart:convert';
import 'package:home_service_app/models/business.dart';

class BusinessDetail {
  final Business business;
  final List<Review> reviews;
  final List<Service> services;

  BusinessDetail({
    required this.business,
    required this.reviews,
    required this.services,
  });

  factory BusinessDetail.fromJson(Map<String, dynamic> json) {
    return BusinessDetail(
      business: Business.fromJson(json['business']),
      reviews:
          (json['reviews'] as List).map((e) => Review.fromJson(e)).toList(),
      services:
          (json['services'] as List).map((e) => Service.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business': business.toJson(),
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'services': services.map((e) => e.toJson()).toList(),
    };
  }
}

class Review {
  final int id;
  final int businessId;
  final int userId;
  final String name;
  final int rating;
  final String comment;
  final String? response;
  final String? responseDate;
  final String? status;
  final List<String> images;
  final String date;

  Review({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.name,
    required this.rating,
    required this.comment,
    this.response,
    this.responseDate,
    this.status,
    required this.images,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      businessId: json['businessId'],
      userId: json['userId'],
      name: json['name'],
      rating: json['rating'],
      comment: json['comment'],
      response: json['response'],
      responseDate: json['responseDate'],
      status: json['status'],
      images: List<String>.from(json['images'] ?? []),
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'userId': userId,
      'name': name,
      'rating': rating,
      'comment': comment,
      'response': response,
      'responseDate': responseDate,
      'status': status,
      'images': images,
      'date': date,
    };
  }
}

class Service {
  final int id;
  final String name;
  final int businessId;
  final String description;
  final double price;
  final String? image;
  final bool available;
  final List<ServiceOption> options;

  Service({
    required this.id,
    required this.name,
    required this.businessId,
    required this.description,
    required this.price,
    this.image,
    required this.available,
    required this.options,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      businessId: json['businessId'],
      description: json['description'],
      price: json['price'].toDouble(),
      image: json['image'],
      available: json['available'],
      options: json['options'] != null
          ? (json['options'] as List)
              .map((e) => ServiceOption.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'businessId': businessId,
      'description': description,
      'price': price,
      'image': image,
      'available': available,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }
}

class ServiceOption {
  final String name;
  final List<String> values;

  ServiceOption({
    required this.name,
    required this.values,
  });

  factory ServiceOption.fromJson(Map<String, dynamic> json) {
    return ServiceOption(
      name: json['name'],
      values: List<String>.from(json['values']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'values': values,
    };
  }
}

class OrderRequest {
  final int businessId;
  final List<OrderItem> items;
  final int serviceLocationId;
  final int paymentMethodId;
  final String scheduledDate;
  final String? specialInstructions;

  OrderRequest({
    required this.businessId,
    required this.items,
    required this.serviceLocationId,
    required this.paymentMethodId,
    required this.scheduledDate,
    this.specialInstructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'businessId': businessId,
      'items': items.map((e) => e.toJson()).toList(),
      'serviceLocationId': serviceLocationId,
      'paymentMethodId': paymentMethodId,
      'scheduledDate': scheduledDate,
      'specialInstructions': specialInstructions,
    };
  }
}

class OrderItem {
  final int serviceId;
  final int quantity;
  final Map<String, String> selectedOptions;
  final String? notes;

  OrderItem({
    required this.serviceId,
    required this.quantity,
    required this.selectedOptions,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'quantity': quantity,
      'selectedOptions': selectedOptions,
      'notes': notes,
    };
  }
}

class ReviewRequest {
  final int businessId;
  final int userId;
  final int rating;
  final String? comment;
  final List<dynamic> images;

  ReviewRequest({
    required this.businessId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'businessId': businessId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'images': images,
    };
  }
}

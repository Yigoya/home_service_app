import 'package:home_service_app/models/customer.dart';

class Review {
  final int id;
  final int bookingId;
  final int customerId;
  final int technicianId;
  final int rating;
  final String review;
  final Customer customer;

  Review({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.technicianId,
    required this.rating,
    required this.review,
    required this.customer,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      bookingId: json['bookingId'],
      customerId: json['customerId'],
      technicianId: json['technicianId'],
      rating: json['rating'],
      review: json['review'],
      customer: Customer.fromJson(json['customer']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'customerId': customerId,
      'technicianId': technicianId,
      'rating': rating,
      'review': review,
      'customer': customer.toJson(),
    };
  }
}

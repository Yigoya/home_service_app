class Customer {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profileImage;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profileImage,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
    };
  }
}

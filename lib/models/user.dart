class User {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final String status;
  final String? profileImage; // Nullable profileImage field

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.status,
    this.profileImage, // Initialize profileImage
  });

  // Factory constructor to create a User instance from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      status: json['status'],
      profileImage: json['profileImage'], // Parse profileImage from JSON
    );
  }

  // Method to convert a User instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'status': status,
      'profileImage': profileImage, // Add profileImage to JSON
    };
  }

  // Method to update a User instance with new data
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? role,
    String? status,
    String? profileImage,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      status: status ?? this.status,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}

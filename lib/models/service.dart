class Service {
  final int id;
  final String name;
  final String? description;
  final double? price;
  final String? duration;
  final int categoryId;
  final String? icon;
  final List<Service> services;

  Service({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.duration,
    required this.categoryId,
    this.icon,
    required this.services,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['serviceId'] ?? json['id'],
      name: json['name'],
      description: json['description'],
      price: json['serviceFee'],
      duration: json['estimatedDuration'],
      categoryId: json['categoryId'],
      icon: json['icon'],
      services: json['services'] != null
          ? json['services'].map<Service>((e) => Service.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'categoryId': categoryId,
      'icon': icon,
      'services': services.map((e) => e.toJson()).toList(),
    };
  }
}

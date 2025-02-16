class Service {
  final int id;
  final String name;
  final String? description;
  final double? price;
  final String? duration;
  final int categoryId;
  final String? icon;
  final bool hasChild;

  Service({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.duration,
    required this.categoryId,
    this.icon,
    required this.hasChild,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      duration: json['duration'],
      categoryId: json['categoryId'],
      icon: json['icon'],
      hasChild: json['hasChild'],
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
      'hasChild': hasChild,
    };
  }
}

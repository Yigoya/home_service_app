class AgencyDetail {
  final int id;
  final int userId;
  final String businessName;
  final String description;
  final String address;
  final String city;
  final String state;
  final String zip;
  final String country;
  final String phone;
  final String website;
  final String document;
  final List<Service> services;
  final String image;

  AgencyDetail({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.description,
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
    required this.phone,
    required this.website,
    required this.document,
    required this.services,
    required this.image,
  });

  factory AgencyDetail.fromJson(Map<String, dynamic> json) {
    return AgencyDetail(
      id: json['id'],
      userId: json['userId'],
      businessName: json['businessName'],
      description: json['description'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zip: json['zip'],
      country: json['country'],
      phone: json['phone'],
      website: json['website'],
      document: json['document'],
      services: (json['services'] as List)
          .map((service) => Service.fromJson(service))
          .toList(),
      image: json['image'],
    );
  }
}

class Service {
  final int id;
  final String name;
  final String description;
  final double price;
  final String duration;
  final int categoryId;
  final int? mobileCategoryId;
  final String? icon;
  final bool hasChild;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.categoryId,
    this.mobileCategoryId,
    this.icon,
    required this.hasChild,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      duration: json['duration'],
      categoryId: json['categoryId'],
      mobileCategoryId: json['mobileCategoryId'],
      icon: json['icon'],
      hasChild: json['hasChild'],
    );
  }
}

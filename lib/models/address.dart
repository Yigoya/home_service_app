class Address {
  final int id;
  final int? customerId;
  final String street;
  final String city;
  final String subcity;
  final String wereda;
  final String? state;
  final String country;
  final String zipCode;
  final double latitude;
  final double longitude;

  Address({
    required this.id,
    this.customerId,
    required this.street,
    required this.city,
    required this.subcity,
    required this.wereda,
    this.state,
    required this.country,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      customerId: json['customerId'],
      street: json['street'],
      city: json['city'],
      subcity: json['subcity'],
      wereda: json['wereda'],
      state: json['state'],
      country: json['country'],
      zipCode: json['zipCode'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'street': street,
      'city': city,
      'subcity': subcity,
      'wereda': wereda,
      'state': state,
      'country': country,
      'zipCode': zipCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

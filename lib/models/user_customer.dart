class UserCustomer {
  final int id;
  final List<String> serviceHistory;
  final List<CustomerAddress> savedAddresses;

  UserCustomer({
    required this.id,
    required this.serviceHistory,
    required this.savedAddresses,
  });

  factory UserCustomer.fromJson(Map<String, dynamic> json) {
    return UserCustomer(
      id: json['id'],
      serviceHistory: List<String>.from(json['serviceHistory']),
      savedAddresses: (json['savedAddresses'] as List)
          .map((address) => CustomerAddress.fromJson(address))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceHistory': serviceHistory,
      'savedAddresses':
          savedAddresses.map((address) => address.toJson()).toList(),
    };
  }
}

class CustomerAddress {
  final String street;
  final String city;
  final String state;
  final String country;
  final String zipCode;
  final double latitude;
  final double longitude;

  CustomerAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      street: json['street'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      zipCode: json['zipCode'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'zipCode': zipCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

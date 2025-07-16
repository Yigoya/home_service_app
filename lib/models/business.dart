import 'dart:convert';

class Business {
  final int id;
  final String name;
  final String description;
  final int ownerId;
  final Location location;
  final String phoneNumber;
  final String email;
  final String website;
  final OpeningHours openingHours;
  final SocialMedia socialMedia;
  final List<String> images;
  final bool isVerified;
  final bool isFeatured;

  Business({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.location,
    required this.phoneNumber,
    required this.email,
    required this.website,
    required this.openingHours,
    required this.socialMedia,
    required this.images,
    required this.isVerified,
    required this.isFeatured,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ownerId: json['ownerId'],
      location:
          Location.fromJson(json['location'] ?? json['locationFromJSON'] ?? {}),
      phoneNumber: json['phoneNumber'] ?? json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      openingHours: OpeningHours.fromJson(
          json['openingHours'] ?? json['openingHoursFromJSON'] ?? {}),
      socialMedia: SocialMedia.fromJson(
          json['socialMedia'] ?? json['socialMediaFromJSON'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
      isVerified: json['isVerified'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'location': location.toJson(),
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
      'openingHours': openingHours.toJson(),
      'socialMedia': socialMedia.toJson(),
      'images': images,
      'isVerified': isVerified,
      'isFeatured': isFeatured,
    };
  }
}

class Location {
  final int? id;
  final String? street;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? name;

  Location({
    this.id,
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.name,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] != null ? json['id'] as int : null,
      street: json['street'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      country: json['country'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'name': name,
    };
  }

  String get fullAddress {
    List<String> parts = [];
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (name != null && name!.isNotEmpty) parts.add(name!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    if (country != null && country!.isNotEmpty) parts.add(country!);

    return parts.join(', ');
  }
}

class OpeningHours {
  final String? mondayOpen;
  final String? mondayClose;
  final String? tuesdayOpen;
  final String? tuesdayClose;
  final String? wednesdayOpen;
  final String? wednesdayClose;
  final String? thursdayOpen;
  final String? thursdayClose;
  final String? fridayOpen;
  final String? fridayClose;
  final String? saturdayOpen;
  final String? saturdayClose;
  final String? sundayOpen;
  final String? sundayClose;

  OpeningHours({
    this.mondayOpen,
    this.mondayClose,
    this.tuesdayOpen,
    this.tuesdayClose,
    this.wednesdayOpen,
    this.wednesdayClose,
    this.thursdayOpen,
    this.thursdayClose,
    this.fridayOpen,
    this.fridayClose,
    this.saturdayOpen,
    this.saturdayClose,
    this.sundayOpen,
    this.sundayClose,
  });

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    return OpeningHours(
      mondayOpen: json['mondayOpen'],
      mondayClose: json['mondayClose'],
      tuesdayOpen: json['tuesdayOpen'],
      tuesdayClose: json['tuesdayClose'],
      wednesdayOpen: json['wednesdayOpen'],
      wednesdayClose: json['wednesdayClose'],
      thursdayOpen: json['thursdayOpen'],
      thursdayClose: json['thursdayClose'],
      fridayOpen: json['fridayOpen'],
      fridayClose: json['fridayClose'],
      saturdayOpen: json['saturdayOpen'],
      saturdayClose: json['saturdayClose'],
      sundayOpen: json['sundayOpen'],
      sundayClose: json['sundayClose'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mondayOpen': mondayOpen,
      'mondayClose': mondayClose,
      'tuesdayOpen': tuesdayOpen,
      'tuesdayClose': tuesdayClose,
      'wednesdayOpen': wednesdayOpen,
      'wednesdayClose': wednesdayClose,
      'thursdayOpen': thursdayOpen,
      'thursdayClose': thursdayClose,
      'fridayOpen': fridayOpen,
      'fridayClose': fridayClose,
      'saturdayOpen': saturdayOpen,
      'saturdayClose': saturdayClose,
      'sundayOpen': sundayOpen,
      'sundayClose': sundayClose,
    };
  }

  String getHoursForDay(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return mondayOpen != null && mondayClose != null
            ? '$mondayOpen - $mondayClose'
            : 'Closed';
      case 'tuesday':
        return tuesdayOpen != null && tuesdayClose != null
            ? '$tuesdayOpen - $tuesdayClose'
            : 'Closed';
      case 'wednesday':
        return wednesdayOpen != null && wednesdayClose != null
            ? '$wednesdayOpen - $wednesdayClose'
            : 'Closed';
      case 'thursday':
        return thursdayOpen != null && thursdayClose != null
            ? '$thursdayOpen - $thursdayClose'
            : 'Closed';
      case 'friday':
        return fridayOpen != null && fridayClose != null
            ? '$fridayOpen - $fridayClose'
            : 'Closed';
      case 'saturday':
        return saturdayOpen != null && saturdayClose != null
            ? '$saturdayOpen - $saturdayClose'
            : 'Closed';
      case 'sunday':
        return sundayOpen != null && sundayClose != null
            ? '$sundayOpen - $sundayClose'
            : 'Closed';
      default:
        return 'N/A';
    }
  }
}

class SocialMedia {
  final String? facebook;
  final String? twitter;
  final String? instagram;
  final String? linkedin;

  SocialMedia({
    this.facebook,
    this.twitter,
    this.instagram,
    this.linkedin,
  });

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      facebook: json['facebook'],
      twitter: json['twitter'],
      instagram: json['instagram'],
      linkedin: json['linkedin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facebook': facebook,
      'twitter': twitter,
      'instagram': instagram,
      'linkedin': linkedin,
    };
  }
}

class PaginatedBusinesses {
  final List<Business> content;
  final int totalPages;
  final int totalElements;
  final int currentPage;
  final int pageSize;
  final bool isFirst;
  final bool isLast;

  PaginatedBusinesses({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.currentPage,
    required this.pageSize,
    required this.isFirst,
    required this.isLast,
  });

  factory PaginatedBusinesses.fromJson(Map<String, dynamic> json) {
    return PaginatedBusinesses(
      content: (json['content'] as List)
          .map((item) => Business.fromJson(item))
          .toList(),
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
      currentPage: json['number'],
      pageSize: json['size'],
      isFirst: json['first'],
      isLast: json['last'],
    );
  }
}

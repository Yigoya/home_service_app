class MarketplaceProduct {
  final int id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final int stockQuantity;
  final int minOrderQuantity;
  final List<String> images;
  final String category;
  final String sku;
  final int businessId;
  final String specifications;
  final List<int> serviceIds;
  final bool active;

  MarketplaceProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.stockQuantity,
    required this.minOrderQuantity,
    required this.images,
    required this.category,
    required this.sku,
    required this.businessId,
    required this.specifications,
    required this.serviceIds,
    required this.active,
  });

  factory MarketplaceProduct.fromJson(Map<String, dynamic> json) {
    return MarketplaceProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'] is int ? json['price'].toDouble() : json['price'],
      currency: json['currency'],
      stockQuantity: json['stockQuantity'],
      minOrderQuantity: json['minOrderQuantity'],
      images: List<String>.from(json['images']),
      category: json['category'],
      sku: json['sku'],
      businessId: json['businessId'],
      specifications: json['specifications'],
      serviceIds: List<int>.from(json['serviceIds']),
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'stockQuantity': stockQuantity,
      'minOrderQuantity': minOrderQuantity,
      'images': images,
      'category': category,
      'sku': sku,
      'businessId': businessId,
      'specifications': specifications,
      'serviceIds': serviceIds,
      'active': active,
    };
  }
}

class PaginatedProducts {
  final List<MarketplaceProduct> content;
  final int totalPages;
  final int totalElements;
  final int currentPage;
  final bool first;
  final bool last;
  final bool empty;

  PaginatedProducts({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.currentPage,
    required this.first,
    required this.last,
    required this.empty,
  });

  factory PaginatedProducts.fromJson(Map<String, dynamic> json) {
    return PaginatedProducts(
      content: (json['content'] as List)
          .map((item) => MarketplaceProduct.fromJson(item))
          .toList(),
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
      currentPage: json['number'],
      first: json['first'],
      last: json['last'],
      empty: json['empty'],
    );
  }
} 
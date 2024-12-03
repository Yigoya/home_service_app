class Category {
  final int id;
  final String categoryName;
  final String? description;

  Category({
    required this.id,
    required this.categoryName,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      categoryName: json['categoryName'],
      description: json['description'],
    );
  }
}

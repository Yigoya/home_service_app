class Subscription {
  final String id;
  final String name;
  final double price; // Price in Ethiopian Birr (ETB)
  final String duration;
  final List<String> features;

  Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.features,
  });
}

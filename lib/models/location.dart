class Location {
  final int id;
  final String englishName;
  final String amharicName;
  final String oromoName;
  final int numberOfWeredas;

  Location({
    required this.id,
    required this.englishName,
    required this.amharicName,
    required this.oromoName,
    required this.numberOfWeredas,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      englishName: json['englishName'],
      amharicName: json['amharicName'],
      oromoName: json['oromoName'],
      numberOfWeredas: json['numberOfWeredas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'englishName': englishName,
      'amharicName': amharicName,
      'oromoName': oromoName,
      'numberOfWeredas': numberOfWeredas,
    };
  }
}

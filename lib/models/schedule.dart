class Schedule {
  int id;
  int technicianId;
  String? mondayStart;
  String? mondayEnd;
  String? tuesdayStart;
  String? tuesdayEnd;
  String? wednesdayStart;
  String? wednesdayEnd;
  String? thursdayStart;
  String? thursdayEnd;
  String? fridayStart;
  String? fridayEnd;
  String? saturdayStart;
  String? saturdayEnd;
  String? sundayStart;
  String? sundayEnd;

  Schedule({
    required this.id,
    required this.technicianId,
    this.mondayStart,
    this.mondayEnd,
    this.tuesdayStart,
    this.tuesdayEnd,
    this.wednesdayStart,
    this.wednesdayEnd,
    this.thursdayStart,
    this.thursdayEnd,
    this.fridayStart,
    this.fridayEnd,
    this.saturdayStart,
    this.saturdayEnd,
    this.sundayStart,
    this.sundayEnd,
  });

  bool get isEmpty {
    return (mondayStart?.isEmpty ?? true) &&
        (mondayEnd?.isEmpty ?? true) &&
        (tuesdayStart?.isEmpty ?? true) &&
        (tuesdayEnd?.isEmpty ?? true) &&
        (wednesdayStart?.isEmpty ?? true) &&
        (wednesdayEnd?.isEmpty ?? true) &&
        (thursdayStart?.isEmpty ?? true) &&
        (thursdayEnd?.isEmpty ?? true) &&
        (fridayStart?.isEmpty ?? true) &&
        (fridayEnd?.isEmpty ?? true) &&
        (saturdayStart?.isEmpty ?? true) &&
        (saturdayEnd?.isEmpty ?? true) &&
        (sundayStart?.isEmpty ?? true) &&
        (sundayEnd?.isEmpty ?? true);
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      technicianId: json['technicianId'],
      mondayStart: json['mondayStart'],
      mondayEnd: json['mondayEnd'],
      tuesdayStart: json['tuesdayStart'],
      tuesdayEnd: json['tuesdayEnd'],
      wednesdayStart: json['wednesdayStart'],
      wednesdayEnd: json['wednesdayEnd'],
      thursdayStart: json['thursdayStart'],
      thursdayEnd: json['thursdayEnd'],
      fridayStart: json['fridayStart'],
      fridayEnd: json['fridayEnd'],
      saturdayStart: json['saturdayStart'],
      saturdayEnd: json['saturdayEnd'],
      sundayStart: json['sundayStart'],
      sundayEnd: json['sundayEnd'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'technicianId': technicianId,
      'mondayStart': mondayStart,
      'mondayEnd': mondayEnd,
      'tuesdayStart': tuesdayStart,
      'tuesdayEnd': tuesdayEnd,
      'wednesdayStart': wednesdayStart,
      'wednesdayEnd': wednesdayEnd,
      'thursdayStart': thursdayStart,
      'thursdayEnd': thursdayEnd,
      'fridayStart': fridayStart,
      'fridayEnd': fridayEnd,
      'saturdayStart': saturdayStart,
      'saturdayEnd': saturdayEnd,
      'sundayStart': sundayStart,
      'sundayEnd': sundayEnd,
    };
  }
}

import 'package:equatable/equatable.dart';
import 'dart:convert';

class JobModel extends Equatable {
  final int id;
  final String title;
  final String description;
  final String companyName;
  final String companyLocation;
  final String jobLocation;
  final String jobType;
  final String salary;
  final String postedDate;
  final String category;
  final String? companyLogo;

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.companyName,
    required this.companyLocation,
    required this.jobLocation,
    required this.jobType,
    required this.salary,
    required this.postedDate,
    required this.category,
    this.companyLogo,
  });

  JobModel copyWith({
    int? id,
    String? title,
    String? description,
    String? companyName,
    String? companyLocation,
    String? jobLocation,
    String? jobType,
    String? salary,
    String? postedDate,
    String? category,
    String? companyLogo,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      companyName: companyName ?? this.companyName,
      companyLocation: companyLocation ?? this.companyLocation,
      jobLocation: jobLocation ?? this.jobLocation,
      jobType: jobType ?? this.jobType,
      salary: salary ?? this.salary,
      postedDate: postedDate ?? this.postedDate,
      category: category ?? this.category,
      companyLogo: companyLogo ?? this.companyLogo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'companyName': companyName,
      'companyLocation': companyLocation,
      'jobLocation': jobLocation,
      'jobType': jobType,
      'salary': salary,
      'postedDate': postedDate,
      'category': category,
      'companyLogo': companyLogo,
    };
  }

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      companyName: map['companyName'] as String,
      companyLocation: map['companyLocation'] as String,
      jobLocation: map['jobLocation'] as String,
      jobType: map['jobType'] as String,
      salary: map['salary'] as String,
      postedDate: map['postedDate'] as String,
      category: map['category'] as String,
      companyLogo: map['companyLogo'] != null ? map['companyLogo'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory JobModel.fromJson(String source) => JobModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'JobModel(id: $id, title: $title, description: $description, companyName: $companyName, jobLocation: $jobLocation, jobType: $jobType, salary: $salary, postedDate: $postedDate, companyLogo: $companyLogo)';
  }
  @override
  List<Object?> get props => [id, title, description, companyName, jobLocation, jobType, salary, postedDate, companyLogo];
}

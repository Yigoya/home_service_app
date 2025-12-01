// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // Added for Color

class JobModel extends Equatable {
  final int id;
  final String title;
  final String description;
  final String companyName;
  final String? companyLocation;
  final String jobLocation;
  final String jobType;
  final String postedDate;
  final String? companyLogo;
  final String category;
  final double salaryMin;
  final double salaryMax;
  final String salaryCurrency;
  final String level;
  final String applicationDeadline;
  final String contactEmail;
  final String contactPhone;
  final List<String> responsibilities;
  final List<String> qualifications;
  final List<String> benefits;
  final List<String> tags;
  final CompanyData companyData;
  final List<JobModel> relatedJobs;

  const JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.companyName,
    this.companyLocation,
    required this.jobLocation,
    required this.jobType,
    required this.postedDate,
    this.companyLogo,
    required this.category,
    required this.salaryMin,
    required this.salaryMax,
    required this.salaryCurrency,
    required this.level,
    required this.applicationDeadline,
    required this.contactEmail,
    required this.contactPhone,
    required this.responsibilities,
    required this.qualifications,
    required this.benefits,
    required this.tags,
    required this.companyData,
    required this.relatedJobs,
  });

  // Getter for formatted salary range
  String get salaryRange {
    String formatSalary(double salary) {
      if (salary >= 1000) {
        // Convert to thousands with 'k' suffix
        double inThousands = salary / 1000;
        if (inThousands == inThousands.toInt()) {
          // If it's a whole number, show as integer
          return '${inThousands.toInt()}k';
        } else {
          // If it has decimals, show with one decimal place
          return '${inThousands.toStringAsFixed(1)}k';
        }
      } else {
        // For amounts less than 1000, add commas
        return salary.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match match) => '${match[1]},',
            );
      }
    }

    String minFormatted = formatSalary(salaryMin);
    String maxFormatted = formatSalary(salaryMax);

    return '$salaryCurrency $minFormatted - $maxFormatted';
  }

  // Getter for average salary
  double get averageSalary {
    return (salaryMin + salaryMax) / 2;
  }

  JobModel copyWith({
    int? id,
    String? title,
    String? description,
    String? companyName,
    String? companyLocation,
    String? jobLocation,
    String? jobType,
    String? postedDate,
    String? companyLogo,
    String? category,
    double? salaryMin,
    double? salaryMax,
    String? salaryCurrency,
    String? level,
    String? applicationDeadline,
    String? contactEmail,
    String? contactPhone,
    List<String>? responsibilities,
    List<String>? qualifications,
    List<String>? benefits,
    List<String>? tags,
    CompanyData? companyData,
    List<JobModel>? relatedJobs,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      companyName: companyName ?? this.companyName,
      companyLocation: companyLocation ?? this.companyLocation,
      jobLocation: jobLocation ?? this.jobLocation,
      jobType: jobType ?? this.jobType,
      postedDate: postedDate ?? this.postedDate,
      companyLogo: companyLogo ?? this.companyLogo,
      category: category ?? this.category,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      salaryCurrency: salaryCurrency ?? this.salaryCurrency,
      level: level ?? this.level,
      applicationDeadline: applicationDeadline ?? this.applicationDeadline,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      responsibilities: responsibilities ?? this.responsibilities,
      qualifications: qualifications ?? this.qualifications,
      benefits: benefits ?? this.benefits,
      tags: tags ?? this.tags,
      companyData: companyData ?? this.companyData,
      relatedJobs: relatedJobs ?? this.relatedJobs,
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
      'postedDate': postedDate,
      'companyLogo': companyLogo,
      'category': category,
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      'salaryCurrency': salaryCurrency,
      'level': level,
      'applicationDeadline': applicationDeadline,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'responsibilities': responsibilities,
      'qualifications': qualifications,
      'benefits': benefits,
      'tags': tags,
      'companyData': companyData.toMap(),
      'relatedJobs': relatedJobs.map((x) => x.toMap()).toList(),
    };
  }

  factory JobModel.fromMap(Map<String, dynamic> map) {
    try {
      return JobModel(
        id: map['id'] as int? ?? 0,
        title: map['title'] as String? ?? '',
        description: map['description'] as String? ?? '',
        companyName: map['companyName'] as String? ?? '',
        companyLocation: map['companyLocation'] as String?,
        jobLocation: map['jobLocation'] as String? ?? '',
        jobType: map['jobType'] as String? ?? '',
        postedDate:
            map['postedDate'] as String? ?? DateTime.now().toIso8601String(),
        companyLogo: map['companyLogo'] as String?,
        category: map['category'] as String? ?? '',
        salaryMin: (map['salaryMin'] as num?)?.toDouble() ?? 0.0,
        salaryMax: (map['salaryMax'] as num?)?.toDouble() ?? 0.0,
        salaryCurrency: map['salaryCurrency'] as String? ?? 'USD',
        level: map['level'] as String? ?? '',
        applicationDeadline: map['applicationDeadline'] as String? ?? '',
        contactEmail: map['contactEmail'] as String? ?? '',
        contactPhone: map['contactPhone'] as String? ?? '',
        responsibilities: List<String>.from(map['responsibilities'] ?? []),
        qualifications: List<String>.from(map['qualifications'] ?? []),
        benefits: List<String>.from(map['benefits'] ?? []),
        tags: List<String>.from(map['tags'] ?? []),
        companyData: CompanyData.fromMap(map['companyData'] ?? {}),
        relatedJobs: List<JobModel>.from(
          (map['relatedJobs'] ?? []).map((x) => JobModel.fromMap(x)),
        ),
      );
    } catch (e) {
      print('Error parsing JobModel: $e');
      print('Map data: $map');
      rethrow;
    }
  }

  String toJson() => json.encode(toMap());

  factory JobModel.fromJson(String source) =>
      JobModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      id,
      title,
      description,
      companyName,
      companyLocation,
      jobLocation,
      jobType,
      postedDate,
      companyLogo,
      category,
      salaryMin,
      salaryMax,
      salaryCurrency,
      level,
      applicationDeadline,
      contactEmail,
      contactPhone,
      responsibilities,
      qualifications,
      benefits,
      tags,
      companyData,
      relatedJobs,
    ];
  }
}

class CompanyData extends Equatable {
  final String name;
  final String? logo;
  final String description;
  final String? industry;
  final String? size;
  final String? founded;
  final String? location;
  final String? website;
  final double? rating;
  final int? totalReviews;
  final int? openJobs;
  final List<String> benefits;
  final List<String> culture;

  const CompanyData({
    required this.name,
    this.logo,
    required this.description,
    this.industry,
    this.size,
    this.founded,
    this.location,
    this.website,
    this.rating,
    this.totalReviews,
    this.openJobs,
    required this.benefits,
    required this.culture,
  });

  CompanyData copyWith({
    String? name,
    String? logo,
    String? description,
    String? industry,
    String? size,
    String? founded,
    String? location,
    String? website,
    double? rating,
    int? totalReviews,
    int? openJobs,
    List<String>? benefits,
    List<String>? culture,
  }) {
    return CompanyData(
      name: name ?? this.name,
      logo: logo ?? this.logo,
      description: description ?? this.description,
      industry: industry ?? this.industry,
      size: size ?? this.size,
      founded: founded ?? this.founded,
      location: location ?? this.location,
      website: website ?? this.website,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      openJobs: openJobs ?? this.openJobs,
      benefits: benefits ?? this.benefits,
      culture: culture ?? this.culture,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'logo': logo,
      'description': description,
      'industry': industry,
      'size': size,
      'founded': founded,
      'location': location,
      'website': website,
      'rating': rating,
      'totalReviews': totalReviews,
      'openJobs': openJobs,
      'benefits': benefits,
      'culture': culture,
    };
  }

  factory CompanyData.fromMap(Map<String, dynamic> map) {
    try {
      return CompanyData(
        name: map['name'] as String? ?? '',
        logo: map['logo'] as String?,
        description: map['description'] as String? ?? '',
        industry: map['industry'] as String?,
        size: map['size'] as String?,
        founded: map['founded'] as String?,
        location: map['location'] as String?,
        website: map['website'] as String?,
        rating:
            map['rating'] != null ? (map['rating'] as num).toDouble() : null,
        totalReviews: map['totalReviews'] as int?,
        openJobs: map['openJobs'] as int?,
        benefits: List<String>.from(map['benefits'] ?? []),
        culture: List<String>.from(map['culture'] ?? []),
      );
    } catch (e) {
      print('Error parsing CompanyData: $e');
      print('Map data: $map');
      // Return a default CompanyData object
      return CompanyData(
        name: '',
        description: '',
        benefits: [],
        culture: [],
      );
    }
  }

  String toJson() => json.encode(toMap());

  factory CompanyData.fromJson(String source) =>
      CompanyData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      name,
      logo,
      description,
      industry,
      size,
      founded,
      location,
      website,
      rating,
      totalReviews,
      openJobs,
      benefits,
      culture,
    ];
  }
}

// Application Model
class ApplicationModel {
  final int id;
  final String candidateName;
  final String email;
  final String phone;
  final String jobTitle;
  final String appliedDate;
  final String status;
  final String experience;
  final String location;
  final String? avatar;
  final String? resumeUrl;
  final String coverLetter;
  final double? rating;
  final String companyName;
  final String? companyLogo;
  final String jobType;
  final String salaryRange;
  final int jobId;
  final int jobSeekerId;
  final String jobSeekerName;
  final String applicationDate;

  ApplicationModel({
    required this.id,
    required this.candidateName,
    required this.email,
    required this.phone,
    required this.jobTitle,
    required this.appliedDate,
    required this.status,
    required this.experience,
    required this.location,
    this.avatar,
    this.resumeUrl,
    required this.coverLetter,
    this.rating,
    required this.companyName,
    this.companyLogo,
    required this.jobType,
    required this.salaryRange,
    required this.jobId,
    required this.jobSeekerId,
    required this.jobSeekerName,
    required this.applicationDate,
  });

  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    return ApplicationModel(
      id: map['id'] ?? 0,
      candidateName: map['candidateName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      appliedDate: map['appliedDate'] ?? '',
      status: map['status'] ?? 'submitted',
      experience: map['experience'] ?? '',
      location: map['location'] ?? '',
      avatar: map['avatar'],
      resumeUrl: map['resumeUrl'],
      coverLetter: map['coverLetter'] ?? '',
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : null,
      companyName: map['companyName'] ?? '',
      companyLogo: map['companyLogo'],
      jobType: map['jobType'] ?? '',
      salaryRange: map['salaryRange'] ?? '',
      jobId: map['jobId'] ?? 0,
      jobSeekerId: map['jobSeekerId'] ?? 0,
      jobSeekerName: map['jobSeekerName'] ?? '',
      applicationDate: map['applicationDate'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'candidateName': candidateName,
      'email': email,
      'phone': phone,
      'jobTitle': jobTitle,
      'appliedDate': appliedDate,
      'status': status,
      'experience': experience,
      'location': location,
      'avatar': avatar,
      'resumeUrl': resumeUrl,
      'coverLetter': coverLetter,
      'rating': rating,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'jobType': jobType,
      'salaryRange': salaryRange,
      'jobId': jobId,
      'jobSeekerId': jobSeekerId,
      'jobSeekerName': jobSeekerName,
      'applicationDate': applicationDate,
    };
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 'In Review';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'shortlisted':
        return 'Shortlisted';
      case 'hired':
        return 'Hired';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'shortlisted':
        return Colors.blue;
      case 'hired':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

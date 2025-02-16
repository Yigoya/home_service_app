import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:home_service_app/screens/auth/waiting_for_approval_page.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/utils/functions.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Technician {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String bio;
  final String? availability;
  final double? rating;
  final String profileImage;

  Technician({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.bio,
    this.availability,
    this.rating,
    required this.profileImage,
  });

  factory Technician.fromJson(Map<String, dynamic> json) {
    return Technician(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      bio: json['bio'],
      availability: json['availability'],
      rating: json['rating']?.toDouble(),
      profileImage: json['profileImage'],
    );
  }
}

class UploadProofPage extends StatefulWidget {
  String? token;

  UploadProofPage({super.key, this.token});

  @override
  State<UploadProofPage> createState() => _UploadProofPageState();
}

class _UploadProofPageState extends State<UploadProofPage> {
  Technician? technician;
  String? message;
  bool isLoading = true;
  File? uploadedFile;
  FlutterSecureStorage storage = const FlutterSecureStorage();
  @override
  void initState() {
    super.initState();
    verifyToken();
  }

  Future<void> verifyToken() async {
    try {
      await storage.write(key: 'verify_token', value: widget.token);
      if (widget.token == null) {
        final token = await storage.read(key: 'verify_token');
        if (token == null) {
          await saveUserStatus(UserStatus.TOKEN_ENTRY);
          setState(() {
            message = AppLocalizations.of(context)!.tokenNotFound;
            isLoading = false;
            return;
          });
        }
        widget.token = token;
      }
      final dio = Dio();
      final url = '${ApiService.API_URL}/auth/verify?token=${widget.token}';
      Logger().d(url);
      final response = await dio.get(url);

      final responseData = response.data;
      setState(() {
        message = responseData['message'];
        technician = Technician.fromJson(responseData['technician']);
        isLoading = false;
      });
      await storage.write(
          key: 'technicianId', value: technician!.id.toString());
    } on DioException catch (e) {
      setState(() {
        message = '${e.response?.data['details'].join(', ')}';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        message = '$e';
        isLoading = false;
      });
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        uploadedFile = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadImage() async {
    if (uploadedFile == null) return;

    try {
      final url = Uri.parse('${ApiService.API_URL}/auth/upload-proof');
      final request = http.MultipartRequest('POST', url)
        ..fields['technicianId'] = technician!.id.toString()
        ..files
            .add(await http.MultipartFile.fromPath('file', uploadedFile!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.ticketUploadedSuccessfully)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.failedToUploadTicket)),
        );
      }
      await saveUserStatus(UserStatus.WAITING_FOR_APPROVAL);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const WaitingForApprovalPage(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AppLocalizations.of(context)!.technicianDetails'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : technician == null
              ? Center(child: Text(message ?? 'Error loading data.'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.0.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 60.r,
                          backgroundImage: NetworkImage(
                              '${ApiService.API_URL_FILE}${technician!.profileImage}'),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        technician!.name,
                        style: TextStyle(
                            fontSize: 22.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.h),
                      Text('Email: ${technician!.email}'),
                      Text('Phone: ${technician!.phoneNumber}'),
                      SizedBox(height: 8.h),
                      Text('Bio: ${technician!.bio}'),
                      SizedBox(height: 8.h),
                      if (technician!.availability != null)
                        Text('Availability: ${technician!.availability}'),
                      if (technician!.rating != null)
                        Text(
                            'Rating: ${technician!.rating?.toStringAsFixed(1)}'),
                      SizedBox(height: 16.h),
                      ElevatedButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(Icons.upload_file),
                        label: Text(AppLocalizations.of(context)!.uploadTicket),
                      ),
                      if (uploadedFile != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                            'Selected file: ${uploadedFile!.path.split('/').last}'),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: uploadImage,
                          child:
                              Text(AppLocalizations.of(context)!.submitTicket),
                        ),
                      ]
                    ],
                  ),
                ),
    );
  }
}

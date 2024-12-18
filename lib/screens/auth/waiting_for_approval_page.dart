import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:logger/logger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WaitingForApprovalPage extends StatefulWidget {
  const WaitingForApprovalPage({super.key});

  @override
  State<WaitingForApprovalPage> createState() => _WaitingForApprovalPageState();
}

class _WaitingForApprovalPageState extends State<WaitingForApprovalPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _checkTechnicianStatus();
  }

  Future<void> _checkTechnicianStatus() async {
    String? technicianId = await _storage.read(key: 'technicianId');
    if (technicianId != null) {
      try {
        final response = await Dio()
            .get('${ApiService.API_URL}/profile/$technicianId/active');
        if (response.statusCode == 200) {
          Logger().d(response.data);
          setState(() {
            _isActive = response.data;
          });
        } else {
          // Handle error
          print('Error: ${response.statusCode}');
        }
      } on DioException catch (dioError) {
        // Handle Dio specific errors
        if (dioError.response != null) {
          print(
              'Dio error: ${dioError.response?.statusCode} - ${dioError.response?.data}');
        } else {
          print('Dio error: ${dioError.message}');
        }
      } catch (e) {
        // Handle other errors
        print('Error: $e');
      }
    } else {
      // Handle missing technicianId
      print('Technician ID is missing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0.w),
          child: _isActive
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 100.sp,
                      color: Colors.green,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "Account Activated",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "Your account has been successfully activated. You can now log in and start using the app.",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30.h),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        "Log In",
                        style: TextStyle(fontSize: 14.sp, color: Colors.white),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 100.sp,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "Waiting for Your Approval",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "Your request is being processed. You will be notified once it has been approved.",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 48.h),
                    ElevatedButton(
                      onPressed: () {
                        _checkTechnicianStatus();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        "Refresh Status",
                        style: TextStyle(fontSize: 14.sp, color: Colors.white),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

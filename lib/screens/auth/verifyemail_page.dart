import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  // Function to open the Gmail app or default mail ap
  Future<void> openGmailApp() async {}

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Open Mail App"),
          content: const Text("No mail apps installed"),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Your Email"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.email_outlined,
              size: 100.sp,
              color: Colors.blueAccent,
            ),
            SizedBox(height: 24.h),
            const Text(
              "Verify Your Email",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              "To continue, please verify your email by clicking the link we sent to your inbox.",
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: openGmailApp,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.open_in_new, size: 24.sp),
                  SizedBox(width: 8.w),
                  const Text("Open Gmail"),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () {
                // Include additional options if they didn’t receive an email
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Resend email feature coming soon!"),
                ));
              },
              child: const Text("Didn't receive the email? Resend"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/l10n/app_localizations.dart';

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
          title: Text(AppLocalizations.of(context)!.openMailApp),
          content: Text(AppLocalizations.of(context)!.noMailAppsInstalled),
          actions: <Widget>[
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.ok),
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
        title: Text(AppLocalizations.of(context)!.verifyYourEmail),
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
            Text(
              AppLocalizations.of(context)!.verifyYourEmail,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context)!.verifyEmailMessage,
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
                  Text(AppLocalizations.of(context)!.openGmail),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () {
                // Include additional options if they didn’t receive an email
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)!
                      .resendEmailFeatureComingSoon),
                ));
              },
              child: Text(AppLocalizations.of(context)!.didntReceiveEmail),
            ),
          ],
        ),
      ),
    );
  }
}

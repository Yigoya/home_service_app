import 'package:flutter/material.dart';
import 'package:home_service_app/screens/auth/upload_proof_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TokenEntryPage extends StatelessWidget {
  TokenEntryPage({super.key});

  final TextEditingController _tokenController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.token,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(
              AppLocalizations.of(context)!.enterToken,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10.h),
            TextFormField(
              controller: _tokenController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.tokenPlaceholder,
                labelText: AppLocalizations.of(context)!.token,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                prefixIcon: const Icon(Icons.vpn_key),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.tokenCannotBeEmpty;
                }
                if (value.length < 16) {
                  return AppLocalizations.of(context)!.tokenTooShort;
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () {
                final token = _tokenController.text.trim();
                if (token.isEmpty || token.length < 16) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.invalidToken,
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                } else {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UploadProofPage(
                            token: _tokenController.text,
                          )));
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 15.h),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 24.sp),
                  SizedBox(width: 10.w),
                  Text(
                    AppLocalizations.of(context)!.submit,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

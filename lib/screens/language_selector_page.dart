import 'package:flutter/material.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelectorPage extends StatelessWidget {
  const LanguageSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Select Language',
            style: TextStyle(color: Colors.white, fontSize: 24)),
        backgroundColor: const Color(0xFF009fff),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose your preferred language',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            ...AppLocalizations.supportedLocales.map((locale) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1.w,
                  ),
                ),
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return CheckboxListTile(
                      title: Text(
                        locale.languageCode == 'en' ? 'English' : 'አማርኛ',
                        style: TextStyle(
                          fontSize: 18.sp,
                        ),
                      ),
                      value: userProvider.locale == locale,
                      onChanged: (bool? value) {
                        if (value == true) {
                          userProvider.changeLanguage(context, locale);
                        }
                      },
                    );
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

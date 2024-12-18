import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF009fff),
            const Color(0xFFec2f4b),
          ],
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Locale>(
          isDense: true,
          value: Localizations.localeOf(context),
          dropdownColor: Colors.grey[800],
          items: AppLocalizations.supportedLocales.map((locale) {
            return DropdownMenuItem(
              value: locale,
              child: Text(
                locale.languageCode == 'en' ? 'English' : 'አማርኛ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            );
          }).toList(),
          onChanged: (locale) {
            if (locale != null) {
              Provider.of<UserProvider>(context, listen: false)
                  .changeLanguage(context, locale);
            }
          },
          icon: const SizedBox.shrink(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:home_service_app/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:provider/provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Locale>(
          isDense: true,
          value: Localizations.localeOf(context),
          items: AppLocalizations.supportedLocales.map((locale) {
            return DropdownMenuItem(
              value: locale,
              child: Text(
                locale.languageCode == 'en' ? 'English' : 'አማርኛ',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
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

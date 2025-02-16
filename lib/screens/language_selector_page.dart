import 'package:flutter/material.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelectorPage extends StatefulWidget {
  const LanguageSelectorPage({super.key});

  @override
  State<LanguageSelectorPage> createState() => _LanguageSelectorPageState();
}

class _LanguageSelectorPageState extends State<LanguageSelectorPage> {
  String _selectedLanguage = 'English';
  // Default selected language
  final List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'አማርኛ', 'code': 'am'},
    {'name': 'Oromiffa', 'code': 'om'},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLanguage = Localizations.localeOf(context).languageCode == 'en'
        ? 'English'
        : Localizations.localeOf(context).languageCode == 'om'
            ? 'Oromiffa'
            : 'አማርኛ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        title: const Text(
          'Language',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 70.h * languages.length,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
          margin: EdgeInsets.all(16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ListView.builder(
            itemCount: languages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  languages[index]['name']! +
                      (languages[index]['name'] == 'English'
                          ? ' (Default)'
                          : ''),
                  style: TextStyle(
                    color: _selectedLanguage == languages[index]['name']
                        ? Theme.of(context).primaryColor
                        : Colors.black,
                  ),
                ),
                trailing: _selectedLanguage == languages[index]['name']
                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                    : null,
                onTap: () {
                  Locale locale = Locale(languages[index]['code']!);
                  Provider.of<UserProvider>(context, listen: false)
                      .changeLanguage(context, locale);
                  setState(() {
                    _selectedLanguage = languages[index]['name']!;
                  });
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

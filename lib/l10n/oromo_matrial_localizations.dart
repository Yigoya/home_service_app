import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OromoMaterialLocalizations extends DefaultMaterialLocalizations {
  OromoMaterialLocalizations(Locale locale) : super();

  @override
  String get okButtonLabel => 'OK (Oromo)'; // Example customization
  // Override other methods as needed
}

class OromoCupertinoLocalizations extends DefaultCupertinoLocalizations {
  OromoCupertinoLocalizations(Locale locale) : super();

  @override
  String get alertDialogLabel => 'Alert (Oromo)'; // Example customization
  // Override other methods as needed
}

class OromoLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const OromoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'om';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return OromoMaterialLocalizations(locale);
  }

  @override
  bool shouldReload(OromoLocalizationsDelegate old) => false;
}

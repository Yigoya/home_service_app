import 'package:flutter/material.dart';

// Primary color (main blue)
const Color kPrimaryColor = Color.fromARGB(255, 37, 99, 235); // #2563EB
const Color kPrimaryDark = Color(0xFF1E40AF); // Darker blue
const Color kPrimaryLight = Color(0xFF60A5FA); // Lighter blue

// Secondary and accent colors
const Color kSecondaryColor = Color(0xFF6366F1); // Indigo
const Color kAccentColor = Color(0xFFF59E42); // Orange/Accent
const Color kSuccessColor = Color(0xFF22C55E); // Green
const Color kWarningColor = Color(0xFFFACC15); // Yellow
const Color kErrorColor = Color(0xFFEF4444); // Red
const Color kInfoColor = Color(0xFF38BDF8); // Light blue

// Greys
const Color kGrey900 = Color(0xFF111827);
const Color kGrey800 = Color(0xFF1F2937);
const Color kGrey700 = Color(0xFF374151);
const Color kGrey600 = Color(0xFF4B5563);
const Color kGrey500 = Color(0xFF6B7280);
const Color kGrey400 = Color(0xFF9CA3AF);
const Color kGrey300 = Color(0xFFD1D5DB);
const Color kGrey200 = Color(0xFFE5E7EB);
const Color kGrey100 = Color(0xFFF3F4F6);
const Color kGrey50 = Color(0xFFFAFAFA);

// Backgrounds
const Color kBackgroundLight = Color(0xFFF4F8FC);
const Color kBackgroundDark = Color(0xFF181A20);

// Text colors
const Color kTextPrimary = kGrey900;
const Color kTextSecondary = kGrey600;
const Color kTextOnPrimary = Colors.white;

// Card and surface
const Color kCardColorLight = Colors.white;
const Color kCardColorDark = Color(0xFF23262B);

// ThemeData for light theme
final ThemeData kLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kPrimaryColor,
  colorScheme: ColorScheme.light(
    primary: kPrimaryColor,
    secondary: kSecondaryColor,
    error: kErrorColor,
    background: kBackgroundLight,
    surface: kCardColorLight,
    onPrimary: kTextOnPrimary,
    onSecondary: Colors.white,
    onError: Colors.white,
    onBackground: kTextPrimary,
    onSurface: kTextPrimary,
  ),
  scaffoldBackgroundColor: kBackgroundLight,
  cardColor: kCardColorLight,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: kTextPrimary),
    titleTextStyle: TextStyle(
      color: kTextPrimary,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
        fontSize: 32, fontWeight: FontWeight.bold, color: kTextPrimary),
    bodyLarge: TextStyle(fontSize: 16, color: kTextPrimary),
    bodyMedium: TextStyle(fontSize: 14, color: kTextSecondary),
    labelLarge: TextStyle(
        fontSize: 14, color: kPrimaryColor, fontWeight: FontWeight.w600),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kPrimaryColor,
    foregroundColor: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kGrey100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    hintStyle: const TextStyle(color: kGrey400),
  ),
);

// ThemeData for dark theme
final ThemeData kDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kPrimaryColor,
  colorScheme: ColorScheme.dark(
    primary: kPrimaryColor,
    secondary: kSecondaryColor,
    error: kErrorColor,
    background: kBackgroundDark,
    surface: kCardColorDark,
    onPrimary: kTextOnPrimary,
    onSecondary: Colors.white,
    onError: Colors.white,
    onBackground: Colors.white,
    onSurface: Colors.white,
  ),
  scaffoldBackgroundColor: kBackgroundDark,
  cardColor: kCardColorDark,
  appBarTheme: const AppBarTheme(
    backgroundColor: kGrey800,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
        fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14, color: kGrey300),
    labelLarge: TextStyle(
        fontSize: 14, color: kPrimaryLight, fontWeight: FontWeight.w600),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kPrimaryColor,
    foregroundColor: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kGrey800,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide.none,
    ),
    hintStyle: const TextStyle(color: kGrey400),
  ),
);

// Reusable Save Button Component
class SaveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double height;

  const SaveButton({
    super.key,
    this.text = 'Save Changes',
    this.onPressed,
    this.width,
    this.height = 45,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
    );
  }
}

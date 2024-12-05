import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:home_service_app/firebase_options.dart';
import 'package:home_service_app/provider/booking_provider.dart';
import 'package:home_service_app/provider/form_provider.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/provider/auth_provider.dart';
import 'package:home_service_app/provider/notification_provider.dart';
import 'package:home_service_app/provider/profile_page_provider.dart';
import 'package:home_service_app/provider/technician_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/auth/token_entery_page.dart';
import 'package:home_service_app/screens/auth/upload_proof_page.dart';
import 'package:home_service_app/screens/auth/waiting_for_approval_page.dart';
import 'package:home_service_app/screens/profile/technician_profile_page.dart';
import 'package:home_service_app/services/deepLink_handler.dart';
import 'package:home_service_app/services/notification_service.dart';
import 'package:home_service_app/utils/functions.dart';
import 'package:home_service_app/utils/route_generator.dart';
import 'package:home_service_app/widgets/bottom_navigation.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:home_service_app/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final locale = await const FlutterSecureStorage().read(key: 'locale');
  final defaultLocale = locale != null ? Locale(locale) : const Locale('en');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => HomeServiceProvider()),
        ChangeNotifierProvider(create: (_) => TechnicianProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ProfilePageProvider()),
        ChangeNotifierProvider(create: (_) => FormProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MyApp(
        defaultLocale: defaultLocale,
      ),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  final Locale defaultLocale;

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  const MyApp({super.key, required this.defaultLocale});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    Provider.of<HomeServiceProvider>(context, listen: false).loadHome(_locale);
  }

  @override
  void initState() {
    super.initState();
    _locale = widget.defaultLocale;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigatorKey.currentContext != null) {
        DynamicLinkHandler.instance.initialize(navigatorKey.currentContext!);
        NotificationService().initialize(navigatorKey.currentContext!);
      } else {
        Logger()
            .e("navigatorKey.currentContext is null, retrying initialization.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(500, 890), // Design size used in the UI design
        minTextAdapt: true,
        builder: (context, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Home Service Platform',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(primarySwatch: Colors.blue),
            onGenerateRoute: RouteGenerator.generateRoute,
            supportedLocales: L10n.all,
            locale: _locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: FutureBuilder(
              future: Future.wait([
                Provider.of<UserProvider>(context, listen: false).loadUser(),
                Provider.of<HomeServiceProvider>(context, listen: false)
                    .loadHome(widget.defaultLocale),
              ]),
              builder: (context, snapshot) {
                final user = Provider.of<UserProvider>(context).user;
                final status = Provider.of<UserProvider>(context).status;
                if (user != null && user.role == "TECHNICIAN") {
                  return const TechnicianProfilePage();
                } else if (status == UserStatus.TOKEN_ENTRY) {
                  return TokenEntryPage();
                } else if (status == UserStatus.PROOF_ENTRY) {
                  return UploadProofPage();
                } else if (status == UserStatus.WAITING_FOR_APPROVAL) {
                  return const WaitingForApprovalPage();
                }
                return const Navigation();
              },
            ),
          );
        });
  }
}

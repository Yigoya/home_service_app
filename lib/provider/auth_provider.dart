import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:home_service_app/main.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/auth/verification_wait_screen.dart';
import 'package:home_service_app/screens/profile/technician_profile_page.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/utils/functions.dart';
import 'package:home_service_app/utils/route_generator.dart';
import 'package:home_service_app/widgets/bottom_navigation.dart';
import 'package:home_service_app/widgets/technician_navigation.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class AuthenticationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final storage = const FlutterSecureStorage();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  File? _ticketImage;
  File? get ticketImage => _ticketImage;

  bool fromAnotherPage = false;

  void setFromAnotherPage(bool value) {
    fromAnotherPage = value;
    notifyListeners();
  }

  Future<void> signup({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    required BuildContext context,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.signup(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

      _isLoading = false;
      showTopMessage(context, 'Signed up successfully');
      notifyListeners();
      Navigator.of(context).pushNamedAndRemoveUntil(
          RouteGenerator.verificationPage, (route) => false);
    } on DioException catch (e) {
      _isLoading = false;
      _errorMessage = e.response?.data['details'].join(', ') ??
          e.response?.data['message'] ??
          'Login failed';
      showTopMessage(context, _errorMessage ?? 'Error occured',
          isSuccess: false);
      notifyListeners();
    } catch (e) {
      showTopMessage(context, e.toString(), isSuccess: false);
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response =
          await _apiService.login(email: email, password: password);
      _isLoading = false;
      notifyListeners();

      if (response.data['user']['status'] == 'INACTIVE' &&
          response.data['user']['role'] == 'CUSTOMER') {
        Navigator.of(context).pushNamedAndRemoveUntil(
            RouteGenerator.verificationPage, (route) => false);
        return;
      }

      if (response.data['user']['status'] == 'INACTIVE' &&
          response.data['user']['role'] == 'TECHNICIAN') {
        Navigator.of(context).pushNamedAndRemoveUntil(
            RouteGenerator.verificationWaitPage, (route) => false);
        return;
      }
      await storage.write(key: "jwt_token", value: response.data['token']);
      await storage.write(
          key: "user", value: jsonEncode(response.data['user']));
      final userLang = response.data['user']['language'];
      final newLocale = userLang != null && userLang == 'AMHARIC'
          ? const Locale('am')
          : const Locale('en');
      MyApp.setLocale(context, newLocale);
      Provider.of<UserProvider>(context).setLocale(newLocale);
      if (response.data['user']['role'] == 'CUSTOMER') {
        await storage.write(
            key: "customer", value: jsonEncode(response.data['customer']));
        await Provider.of<UserProvider>(context, listen: false).loadUser();
        if (fromAnotherPage) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const Navigation()),
              (route) => false);
        }
      } else if (response.data['user']['role'] == 'TECHNICIAN') {
        await storage.write(
            key: "technician", value: jsonEncode(response.data['technician']));
        await Provider.of<UserProvider>(context, listen: false).loadUser();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => const TechnicianNavigation()),
            (route) => false);
      }

      showTopMessage(context, 'Logged in successfully');
    } on DioException catch (e) {
      _isLoading = false;
      _errorMessage = e.response?.data['details'].join(', ') ??
          e.response?.data['message'] ??
          'Login failed';
      showTopMessage(context, _errorMessage ?? 'Error occured',
          isSuccess: false);
      notifyListeners();
    }
    fromAnotherPage = false;
  }

  Future<void> handleGoogleSignIn(BuildContext context) async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    try {
      // Step 1: Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print("Google Sign-In aborted.");
        return;
      }

      // Step 2: Obtain the authentication details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Step 3: Create a new credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Sign in with Firebase
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Step 5: Get the signed-in user
      User? user = userCredential.user;

      String? name = user?.displayName;
      String? email = user?.email;
      String? phoneNumber = user?.phoneNumber;

      // // Step 6: Handle missing details dynamically
      // if (name == null || email == null || phoneNumber == null) {
      //   Map<String, String?> updatedDetails = await _collectUserDetails(
      //     context,
      //     missingName: name == null,
      //     missingEmail: email == null,
      //     missingPhoneNumber: phoneNumber == null,
      //   );
      //   name = updatedDetails['name'] ?? name;
      //   email =
      //       updatedDetails['email']!.isEmpty ? email : updatedDetails['email'];
      //   phoneNumber = updatedDetails['phoneNumber'] ?? phoneNumber;
      // }

      // Step 7: Log the user details
      Logger().d({
        "User Name": name,
        "User Email": email,
        "User Phone Number": phoneNumber,
      });

      final FCMToken = await storage.read(key: "fcm_token");
      final deviceInfo = await getDeviceInfo();

      Dio dio = Dio();
      final response = await dio.post(
        '${ApiService.API_URL}/auth/social-login',
        data: {
          "idToken": await FirebaseAuth.instance.currentUser?.getIdToken(true),
          "name": name,
          "email": email,
          "phoneNumber": phoneNumber,
          "provider": "google",
          "FCMToken": FCMToken,
          "deviceType": deviceInfo["deviceType"],
          "deviceModel": deviceInfo["deviceModel"],
          "operatingSystem": deviceInfo["operatingSystem"]
        },
      );
      Logger().d(response.data);
      await storage.write(key: "jwt_token", value: response.data['token']);
      await storage.write(
          key: "user", value: jsonEncode(response.data['user']));
      if (response.data['user']['role'] == 'CUSTOMER') {
        await storage.write(
            key: "customer", value: jsonEncode(response.data['customer']));
        await Provider.of<UserProvider>(context, listen: false).loadUser();
        if (fromAnotherPage) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const Navigation()),
              (route) => false);
        }
      } else if (response.data['user']['role'] == 'TECHNICIAN') {
        await storage.write(
            key: "technician", value: jsonEncode(response.data['technician']));
        await Provider.of<UserProvider>(context, listen: false).loadUser();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => const TechnicianProfilePage()),
            (route) => false);
      } else {
        showTopMessage(
            context, "${response.data['user']['role']} not supported",
            isSuccess: false);
        googleUser.clearAuthCache();
        await GoogleSignIn().signOut();
      }

      Logger().d(response.data);
    } on DioException catch (e) {
      Logger().e(e.response!.data);
      print("Error during Google Sign-In: $e");
    } catch (e) {
      print("Error during Google Sign-In: $e");
    }
  }

  Future<void> registerTechnician(
      FormData technician, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await ApiService().technicianSignup(technician);

      if (response.statusCode == 200) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => const VerificationWaitPage()),
            (route) => false);
      }
      saveUserStatus(UserStatus.TOKEN_ENTRY);
      _isLoading = false;
      showTopMessage(context, 'Registered successfully');
      notifyListeners();
    } on DioException catch (e) {
      Logger().e(e.response!.data);
      _isLoading = false;
      _errorMessage = e.response?.data['details'].join(', ') ??
          e.response?.data['message'] ??
          'Login failed';
      showTopMessage(context, _errorMessage ?? 'Error occured',
          isSuccess: false);
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      showTopMessage(context, _errorMessage ?? 'Error occured',
          isSuccess: false);
      notifyListeners();
    }
  }

  Future<bool> requestPasswordReset(String email, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _apiService
          .postRequestWithoutToken('/auth/password-reset-request', {
        "email": email,
      });
      _isLoading = false;
      showTopMessage(context, response.data);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _isLoading = false;
      _errorMessage = e.response?.data['details'].join(', ') ??
          e.response?.data['message'] ??
          'Request failed';
      showTopMessage(context, _errorMessage ?? 'Error occured',
          isSuccess: false);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      showTopMessage(context, _errorMessage ?? 'Error occured',
          isSuccess: false);
      notifyListeners();
      return false;
    }
  }

  Future<void> resetPassword(
      String token, String newPassword, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response =
          await _apiService.postRequestWithoutToken('/auth/reset-password', {
        "token": token,
        "password": newPassword,
      });
      _isLoading = false;
      showTopMessage(context, response.data);
      Navigator.of(context)
          .pushNamedAndRemoveUntil(RouteGenerator.loginPage, (route) => false);
      notifyListeners();
    } on DioException catch (e) {
      _isLoading = false;
      _errorMessage = e.response?.data['details'].join(', ') ??
          e.response?.data['message'] ??
          'Request failed';
      showTopMessage(context, _errorMessage ?? 'Error occured',
          isSuccess: false);

      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      showTopMessage(context, _errorMessage ?? 'Error occured',
          isSuccess: false);
      notifyListeners();
    }
  }

  void uploadTicket(File image) {
    _ticketImage = image;
    notifyListeners();
  }
}

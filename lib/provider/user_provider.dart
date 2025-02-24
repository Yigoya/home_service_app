import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:home_service_app/main.dart';
import 'package:home_service_app/models/dispute.dart';
import 'package:home_service_app/models/user_customer.dart';
import 'package:home_service_app/models/user.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/utils/functions.dart';
import 'package:logger/web.dart';

class UserProvider with ChangeNotifier {
  ApiService apiService = ApiService();
  final storage = const FlutterSecureStorage();
  User? _user;
  UserCustomer? _customer;

  UserStatus status = UserStatus.GUEST;

  List<Dispute> _disputes = [];

  List<Dispute> get disputes => _disputes;

  User? get user => _user;
  UserCustomer? get customer => _customer;
  int coin = 0;
  Locale locale = const Locale('en');

  String get languageCode => locale.languageCode;

  bool isLoading = false;
  // Load user data from secure storage

  Future<void> setLocale(Locale newLocale) async {
    locale = newLocale;
    await storage.write(key: 'locale', value: newLocale.languageCode);
    notifyListeners();
  }

  Future<void> loadUser() async {
    String? status = await storage.read(key: 'user_status');
    if (status != null) {
      this.status = UserStatus.values
          .firstWhere((element) => element.name == status, orElse: () {
        return UserStatus.GUEST;
      });
    }

    final userData = await storage.read(key: "user");
    if (userData != null) {
      _user = User.fromJson(jsonDecode(userData));
      if (_user!.role == "CUSTOMER") {
        final customerData = await storage.read(key: "customer");
        if (customerData != null) {
          _customer = UserCustomer.fromJson(jsonDecode(customerData));
        }

        try {
          final response =
              await apiService.getRequest('/coins/balance/${_customer!.id}');
          Logger().d(response.data);
          coin = response.data;
        } on DioException catch (e) {
          Logger().e(e.response != null ? e.response!.data : e.message);
        } catch (e) {
          Logger().e(e);
        }
      } else if (_user!.role == "TECHNICIAN") {
        final technicianData = await storage.read(key: "technician");
      }
    }
    notifyListeners();
  }

  Future<void> fetchDispute() async {
    isLoading = true;
    notifyListeners();
    try {
      Logger().d(_customer!.id);
      final res =
          await apiService.getRequest('/disputes/customer/${_customer!.id}');

      final data = res.data;
      Logger().d(data);
      if (data.isNotEmpty) {
        _disputes = data.map<Dispute>((e) => Dispute.fromJson(e)).toList();
      }
      notifyListeners();
    } on DioException catch (e) {
      Logger().e(e.response!.data);
    } catch (e) {
      Logger().e(e);
    }

    isLoading = false;
    notifyListeners();
  }

  // Clear user data for logout
  Future<void> clearUser() async {
    final fcmToken = await storage.read(key: "fcm_token");
    await storage.deleteAll();
    Logger().d("FCM Token: $fcmToken");
    if (fcmToken != null) {
      await storage.write(key: "fcm_token", value: fcmToken);
    }
    await GoogleSignIn().signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> buyCoin(int amount) async {
    try {
      final data = {
        'customerId': _customer!.id,
        'coinAmount': amount,
      };
      final response = await apiService.postRequest('/coins/purchase', data);
    } on DioException catch (e) {
      Logger().e(e.response!.data);
    } catch (e) {
      Logger().e(e);
    }
  }

  Future<void> checkBalance() async {
    try {
      final response =
          await apiService.getRequest('/coins/balance/${_customer!.id}');
      coin = response.data['coin'];
      notifyListeners();
    } on DioException catch (e) {
      Logger().e(e.response!.data);
    } catch (e) {
      Logger().e(e);
    }
  }

  Future<void> changeLanguage(BuildContext context, Locale newLocale) async {
    try {
      MyApp.setLocale(context, newLocale);
      await storage.write(key: 'locale', value: newLocale.languageCode);

      if (user != null) {
        final data = {
          'preferredLanguage':
              newLocale.languageCode == 'am' ? "AMHARIC" : "ENGLISH",
        };
        final response = await apiService.patchRequest(
            '/profile/${user!.id}/preferred-language', data);
      }
      locale = newLocale;
      // Provider.of<HomeServiceProvider>(context, listen: false).loadHome(locale);
      // notifyListeners();
    } on DioException catch (e) {
      Logger().e(e.response!.data);
    } catch (e) {
      Logger().e(e);
    }
  }

  Future<void> changeEmail(String newEmail, BuildContext context) async {
    try {
      final data = {
        'userId': _user!.id,
        'email': newEmail,
      };
      final response =
          await apiService.postRequest('/profile/change-email', data);

      await storage.write(key: 'user', value: jsonEncode(_user!.toJson()));
      showTopMessage(context, response.data);
      notifyListeners();
    } on DioException catch (e) {
      if (e.response != null) {
        Logger().e(e.response!.data);
        showTopMessage(context, e.response!.data['details'].join('\n'),
            isSuccess: false);
      } else {
        Logger().e(e.message);
        showTopMessage(context, e.message!, isSuccess: false);
      }
    } catch (e) {
      Logger().e(e);
    }
  }

  Future<void> changePhoneNumber(
      String newPhoneNumber, BuildContext context) async {
    try {
      final data = {
        'userId': _user!.id,
        'phoneNumber': newPhoneNumber,
      };
      final response =
          await apiService.postRequest('/profile/change-phone', data);

      // await storage.write(key: 'user', value: jsonEncode(_user!.toJson()));
      showTopMessage(context, response.data);
      notifyListeners();
    } on DioException catch (e) {
      if (e.response != null) {
        Logger().e(e.response!.data);
        showTopMessage(context, e.response!.data['details'].join('\n'),
            isSuccess: false);
      } else {
        Logger().e(e.message);
        showTopMessage(context, e.message!, isSuccess: false);
      }
    } catch (e) {
      Logger().e(e);
    }
  }

  bool validateForm({
    required String firstName,
    required String lastName,
    required String emailOrMobile,
    required String tenderReceiveVia,
    required String contactId,
    required String category,
    required String password,
  }) {
    // Basic validation (expand as needed)
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        emailOrMobile.isEmpty ||
        tenderReceiveVia.isEmpty ||
        contactId.isEmpty ||
        category.isEmpty ||
        password.isEmpty) {
      return false;
    }
    // Add email/mobile validation logic here (e.g., regex for email or phone)
    return true;
  }
}

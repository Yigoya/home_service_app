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

  // Load user data from secure storage
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
          Logger().e(e.response!.data);
        } catch (e) {
          Logger().e(e);
        }
      } else if (_user!.role == "TECHNICIAN") {
        final technicianData = await storage.read(key: "technician");
      }
      notifyListeners();
    }
  }

  Future<void> fetchDispute() async {
    // Load disputes from API
    try {
      final res =
          await apiService.getRequest('/disputes/customer/${_customer!.id}');

      final data = res.data;
      Logger().d(data);
      _disputes = data.map<Dispute>((e) => Dispute.fromJson(e)).toList();
      notifyListeners();
    } on DioException catch (e) {
      Logger().e(e.response!.data);
    } catch (e) {
      Logger().e(e);
    }
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

  Future<void> changeLanguage(BuildContext context, Locale locale) async {
    try {
      MyApp.setLocale(context, locale);
      await storage.write(key: 'locale', value: locale.languageCode);
      final data = {
        'customerId': _customer!.id,
        'preferredLanguage':
            locale.languageCode == 'am' ? "AMHARIC" : "ENGLISH",
      };

      final response = await apiService.patchRequest(
          '/profile/${user!.id}/preferred-language', data);
    } on DioException catch (e) {
      Logger().e(e.response!.data);
    } catch (e) {
      Logger().e(e);
    }
  }
}

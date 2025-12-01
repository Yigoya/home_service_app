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
import 'package:home_service_app/provider/job_provider.dart';
import 'package:provider/provider.dart';
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
      } else if (_user!.role == "JOB_SEEKER" || _user!.role == "USER") {
        // Automatically fetch job seeker profile for JOB_SEEKER and USER users
        await fetchJobSeekerProfile();
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
    _customer = null;
    clearJobSeekerProfile(); // Clear job seeker profile data

    // Clear saved jobs when user logs out
    try {
      final jobProvider =
          Provider.of<JobProvider>(navigatorKey.currentContext!, listen: false);
      jobProvider.clearSavedJobs();
    } catch (e) {
      Logger().e('Error clearing saved jobs on logout: $e');
    }

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
      Navigator.of(context).popUntil((route) => route.isFirst);
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

  // Job Seeker Profile Management
  Map<String, dynamic>? _jobSeekerProfile;
  bool _isLoadingJobSeeker = false;

  Map<String, dynamic>? get jobSeekerProfile => _jobSeekerProfile;
  bool get isLoadingJobSeeker => _isLoadingJobSeeker;

  // Fetch job seeker profile from API
  Future<void> fetchJobSeekerProfile() async {
    if (_user == null) {
      Logger().e('No user available to fetch job seeker profile');
      return;
    }

    Logger()
        .d('Starting to fetch job seeker profile for user: ${_user!.toJson()}');
    _isLoadingJobSeeker = true;
    notifyListeners();

    try {
      Logger().d('Fetching job seeker profile for user ID: ${_user!.id}');
      final response =
          await apiService.getRequest('/profiles/seeker/${_user!.id}');

      Logger().d('Job Seeker Profile API Response: ${response.data}');

      if (response.statusCode == 200) {
        _jobSeekerProfile = Map<String, dynamic>.from(response.data);
        Logger().d('Job seeker profile fetched successfully');
      } else {
        Logger()
            .e('Failed to fetch job seeker profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      Logger().e('DioException while fetching job seeker profile: $e');
      Logger().e('Response: ${e.response?.data}');
    } catch (e) {
      Logger().e('Unexpected error while fetching job seeker profile: $e');
    }

    _isLoadingJobSeeker = false;
    notifyListeners();
  }

  // Update job seeker profile
  Future<void> updateJobSeekerProfile(Map<String, dynamic> profileData) async {
    if (_user == null) {
      Logger().e('No user available to update job seeker profile');
      return;
    }

    _isLoadingJobSeeker = true;
    notifyListeners();

    try {
      Logger().d('Updating job seeker profile for user ID: ${_user!.id}');
      final formData = FormData.fromMap(profileData);
      final response = await apiService.putRequestWithFormData(
          '/profiles/seeker/${_user!.id}', formData);

      Logger().d('Job Seeker Profile Update Response: ${response.data}');

      if (response.statusCode == 200) {
        // Refresh the profile data
        await fetchJobSeekerProfile();
        Logger().d('Job seeker profile updated successfully');
      } else {
        Logger()
            .e('Failed to update job seeker profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      Logger().e('DioException while updating job seeker profile: $e');
      Logger().e('Response: ${e.response?.data}');
    } catch (e) {
      Logger().e('Unexpected error while updating job seeker profile: $e');
    }

    _isLoadingJobSeeker = false;
    notifyListeners();
  }

  // Clear job seeker profile data (for logout)
  void clearJobSeekerProfile() {
    _jobSeekerProfile = null;
    _isLoadingJobSeeker = false;
    notifyListeners();
  }

  // Get job seeker profile data with fallback
  Map<String, dynamic>? getJobSeekerInfo() {
    return _jobSeekerProfile;
  }

  // Check if user is a job seeker
  bool get isJobSeeker {
    // Check for both JOB_SEEKER role and USER role (since job finder users might have USER role)
    return _user?.role == "JOB_SEEKER" || _user?.role == "USER";
  }
}

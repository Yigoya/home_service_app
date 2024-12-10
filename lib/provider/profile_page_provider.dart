import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:home_service_app/models/booking.dart';
import 'package:home_service_app/models/schedule.dart';
import 'package:home_service_app/models/techinician_detail.dart';
import 'package:home_service_app/models/user.dart';
import 'package:home_service_app/models/user_customer.dart';
import 'package:home_service_app/models/user_technician.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:logger/web.dart';

class ProfilePageProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final storage = const FlutterSecureStorage();

  List<Booking> _bookings = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  User? _user;

  List<Booking> get bookings => _bookings;

  UserCustomer? _customer;

  UserTechnician? _technician;

  Schedule _schedule = Schedule(id: 1, technicianId: 1);

  Schedule get schedule => _schedule;

  List<Map<String, dynamic>>? calender;
  Map<String, dynamic> techinicianDetail = {};

  Future<void> fetchBookings() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userData = await storage.read(key: "user");
      if (userData != null) {
        _user = User.fromJson(jsonDecode(userData));
      }

      if (_user!.role == "TECHNICIAN") {
        final technicianData = await storage.read(key: "technician");
        if (technicianData != null) {
          Logger().d(technicianData);
          _technician = UserTechnician.fromJson(jsonDecode(technicianData));
        }
        final technicianId = _technician!.id;
        final response =
            await _apiService.getRequest('/booking/technician/$technicianId');

        final data = response.data['content'] as List;
        _bookings = data.map<Booking>((e) => Booking.fromJson(e)).toList();

        _isLoading = false;
        notifyListeners();
      } else {
        final customerData = await storage.read(key: "customer");
        if (customerData != null) {
          _customer = UserCustomer.fromJson(jsonDecode(customerData));
        }
        final cusstomerId = _customer!.id;
        Logger().d(cusstomerId);
        final response =
            await _apiService.getRequest('/booking/customer/$cusstomerId');

        final data = response.data['content'] as List;
        Logger().d(data);
        _bookings = data.map<Booking>((e) => Booking.fromJson(e)).toList();

        _isLoading = false;
        notifyListeners();
      }
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      Logger().e(e.response!.data);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();
      if (_user!.role == "TECHNICIAN") {
        final response = await _apiService.putRequest(
            '/profile/technician/${_technician!.id}', data);

        final userData = response.data;
        Logger().d(userData);
        User newUser = _user!.copyWith(
          name: data['name'],
        );
        await storage.write(key: "user", value: jsonEncode(newUser.toJson()));
      } else {
        final response = await _apiService.putRequest(
            '/profile/customer/${_customer!.id}', data);

        final userData = response.data;
        Logger().d(userData);
        User newUser = _user!.copyWith(
          name: data['name'],
        );
        await storage.write(key: "user", value: jsonEncode(newUser.toJson()));
      }
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      Logger().e(e.response!.data);
    }
  }

  Future<void> uploadProfileImage(FormData data) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.multiPartRequest(
          '/profile/uploadProfileImage/${_user!.id}', data);

      final userData = response.data;
      Logger().d(userData);
      User newUser = _user!.copyWith(
        profileImage: userData['profileImage'],
      );
      await storage.write(key: "user", value: jsonEncode(newUser.toJson()));

      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      Logger().e(e.response!.data);
    }
  }

  Future<void> setSchedule(Schedule schedule) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.postRequest(
          '/profile/technician/${_technician!.id}/weekly-schedule',
          schedule.toJson());

      final data = response.data;
      Logger().d(data);
    } on DioException catch (e) {
      Logger().e(e.response);
    } catch (e) {
      Logger().e(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTechnicianProfile() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService
          .getRequest('/profile/technician/${_technician!.id}');
      final data = response.data;
      Logger().d(data);
      techinicianDetail = data as Map<String, dynamic>;
      if (data['weeklySchedule'] != null) {
        _schedule = Schedule.fromJson(data['weeklySchedule']);
      }
      calender = (data['calender'] as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      Logger().e(e);
    }
  }
}

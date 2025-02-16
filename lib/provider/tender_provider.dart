import 'package:flutter/material.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/models/tender.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:logger/web.dart';

class TenderProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Tender> _tenders = [];
  List<Tender> _filteredTenders = [];
  bool _isLoading = false;
  String _errorMessage = '';
  int totalTenders = 0;
  int page = 0;
  int size = 10;

  List<Tender> get tenders => _filteredTenders;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Tender? _tender;

  Tender? get tender => _tender;

  Future<void> fetchTender(int id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _apiService.getRequest("/tenders/$id");

      if (response.statusCode == 200) {
        _tender = Tender.fromJson(response.data);
      } else {
        _errorMessage = "Failed to load tender details.";
      }
    } catch (e) {
      _errorMessage = "An error occurred: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTenders(int serviceId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _apiService
          .getRequest('/tenders/service/$serviceId?page=$page&size=$size');

      if (response.statusCode == 200) {
        List<dynamic> jsonData = response.data["content"];
        Logger().d(jsonData);
        _tenders = jsonData.map((data) => Tender.fromJson(data)).toList();
        _filteredTenders = List.from(_tenders);
        totalTenders = response.data["totalElements"];
      } else {
        _errorMessage = "Failed to load tenders.";
      }
    } catch (e) {
      _errorMessage = "An error occurred: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  void searchTenders(String query) {
    if (query.isEmpty) {
      _filteredTenders = List.from(_tenders);
    } else {
      _filteredTenders = _tenders
          .where((tender) =>
              tender.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<void> filterByLocation(String location, int serviceId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      print(location + serviceId.toString());
      final response = await _apiService.getRequest(
          '/tenders/location-service?location=$location&serviceId=$serviceId');

      if (response.statusCode == 200) {
        List<dynamic> jsonData = response.data["content"];
        print(jsonData);
        _filteredTenders =
            jsonData.map((data) => Tender.fromJson(data)).toList();
      } else {
        _errorMessage = "Failed to filter tenders.";
      }
    } catch (e) {
      _errorMessage = "An error occurred: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Service>> loadSubServices(int serviceId) async {
    List<Service> subServices = [];
    try {
      print(serviceId);
      final res = await _apiService
          .getRequestWithoutToken('/services/$serviceId/subservices');
      final data = res.data;
      subServices = data.map<Service>((e) => Service.fromJson(e)).toList();
    } catch (e) {
      Logger().e(e);
    }

    return subServices;
  }
}

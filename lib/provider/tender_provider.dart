import 'package:flutter/material.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/models/tender.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:intl/intl.dart';

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
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  List<Tender> get tenders => _filteredTenders;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Tender? _tender;

  Tender? get tender => _tender;

  TextEditingController keywordController = TextEditingController();

  String? status;
  DateTime? datePosted;
  DateTime? closingDate;
  String? location;
  Service? service;

  void setStatus(String? val) {
    status = val;
    notifyListeners();
  }

  void setDatePosted(DateTime val) {
    datePosted = val;
    notifyListeners();
  }

  void setClosingDate(DateTime val) {
    closingDate = val;
    notifyListeners();
  }

  void setLocation(String val) {
    location = val;
    notifyListeners();
  }

  void setService(Service? service) {
    service = service;
    notifyListeners();
  }

  Future<void> advanceTenders() async {
    print("Advance");
    Map<String, dynamic> searchParams = {
      "keyword":
          keywordController.text.isNotEmpty ? keywordController.text : null,
      "status": status,
      "location": location,
      "serviceId": service?.id,
      "datePosted": datePosted != null ? _dateFormat.format(datePosted!) : null,
      "closingDate":
          closingDate != null ? _dateFormat.format(closingDate!) : null,
      "page": 0,
      "size": 10,
    };

    try {
      final response = await _apiService.postRequestWithoutToken(
        "/tenders/search",
        searchParams,
      );
      List<dynamic> jsonData = response.data["content"];
      Logger().d(jsonData);
      _tenders = jsonData.map((data) => Tender.fromJson(data)).toList();
      _filteredTenders = List.from(_tenders);
      totalTenders = response.data["totalElements"];
      print("Fetched Tenders: ${response.data}");
    } catch (e) {
      print("Error fetching tenders: $e");
    }
  }

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

import 'package:flutter/material.dart';
import 'package:home_service_app/models/agency.dart';
import 'package:home_service_app/models/agency_detail.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:logger/logger.dart';

class AgencyProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Agency> _agencies = [];
  List<Agency> _filteredAgencies = [];
  Agency? agency;
  bool _isLoading = false;
  String _errorMessage = '';

  List<Agency> get agencies => _agencies;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  List<Agency> get filteredAgencies => _filteredAgencies;

  Future<void> fetchAgencies(int categoryId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    print(categoryId);
    try {
      final response = await _apiService
          .getRequestWithoutToken('/agencies/service/$categoryId');
      if (response.statusCode == 200) {
        Logger().d(response.data);
        _agencies = (response.data as List)
            .map((agency) => Agency.fromJson(agency))
            .toList();
        _filteredAgencies = _agencies;
      } else {
        _errorMessage = 'Failed to load agencies';
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAgencyDetails(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response =
          await _apiService.getRequestWithoutToken("/agencies/$id");
      print(response.data);
      agency = Agency.fromJson(response.data);
    } catch (e) {
      print("Error fetching agency details: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  void searchAgenciesByName(String name) {
    _filteredAgencies = _agencies
        .where((agency) =>
            agency.businessName.toLowerCase().contains(name.toLowerCase()))
        .toList();
    notifyListeners();
  }
}

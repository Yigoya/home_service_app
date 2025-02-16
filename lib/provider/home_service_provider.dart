import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:home_service_app/models/catagory.dart';
import 'package:home_service_app/models/dispute.dart';
import 'package:home_service_app/models/faq.dart';
import 'package:home_service_app/models/location.dart';
import 'package:home_service_app/models/rating.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/models/techinician_detail.dart';
import 'package:home_service_app/models/technician.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/utils/functions.dart';
import 'package:logger/web.dart';

class HomeServiceProvider with ChangeNotifier {
  bool isLoading = false;
  TechinicianDetail? _techinicianDetail;

  TechinicianDetail? get techinicianDetail => _techinicianDetail;
  ApiService apiService = ApiService();

  List<Category> _categories = [];
  Location? selectedLocation;
  List<Location> locations = [
    Location(
      englishName: 'Addis Ababa',
      amharicName: 'አዲስ አበባ',
      oromoName: 'Finfinne',
      numberOfWeredas: 10,
    ),
    Location(
      englishName: 'Dire Dawa',
      amharicName: 'ድሬ ዳዋ',
      oromoName: 'Dirre Dhawaa',
      numberOfWeredas: 5,
    ),
    Location(
      englishName: 'Harar',
      amharicName: 'ሐረር',
      oromoName: 'Harar',
      numberOfWeredas: 6,
    ),
  ];

  List<Service> _services = [];

  List<Service> _selectedServices = [];

  List<Service> _fiterableByCatagory = [];

  List<Service> _fiterableBySearch = [];

  List<Category> get categories => _categories;

  List<Service> get services => _services;

  List<Technician> _technicians = [];

  List<Technician> _topTechnicians = [];

  final List<Dispute> _disputes = [];

  List<Review> _reviews = [];

  List<Technician> get technicians => _technicians;
  List<Technician> get topTechnicians => _topTechnicians;
  List<Review> get reviews => _reviews;
  List<FAQ> get faqs => _faqs;
  List<Service> get fiterableByCatagory => _fiterableByCatagory;
  List<Service> get fiterableBySearch => _fiterableBySearch;
  int selectedCategoryId = 0;
  Category? get selectedCategory =>
      _categories.firstWhere((element) => element.id == selectedCategoryId);
  int totalPages = 1;
  int totalElements = 0;
  List<Map<String, dynamic>> questions = [];
  Locale locale = const Locale('en');

  List<String> subCitys(Locale locale) {
    switch (locale.languageCode) {
      case 'am':
        return locations.map((location) => location.amharicName).toList();
      case 'om':
        return locations.map((location) => location.oromoName).toList();
      default:
        return locations.map((location) => location.englishName).toList();
    }
  }

  void selectLocation(Location location) {
    selectedLocation = location;
    notifyListeners();
  }

  String subCityNameInLanguage(Location? location, Locale locale) {
    if (location == null) {
      return '';
    }
    switch (locale.languageCode) {
      case 'am':
        return location.amharicName;
      case 'om':
        return location.oromoName;
      default:
        return location.englishName;
    }
  }

  List<String> get weredas {
    if (selectedLocation == null) {
      return [];
    }
    return List<String>.generate(
      selectedLocation!.numberOfWeredas,
      (index) => (index + 1).toString().padLeft(2, '0'),
    );
  }

  Future<void> loadHome(Locale newLocate) async {
    locale = newLocate;
    notifyListeners();
    try {
      final res = await apiService.getRequestByQueryWithoutToken('/home', {
        'lang': locale.languageCode == 'om'
            ? 'OROMO'
            : locale.languageCode == 'am'
                ? 'AMHARIC'
                : 'ENGLISH',
      });
      final topFiveTechnicians = res.data['topFiveTechnicians'];
      final services = res.data['services'];
      final topFiveReviews = res.data['topFiveReviews'];
      final serviceCategories = res.data['serviceCategories'];

      try {
        _topTechnicians = topFiveTechnicians
            .map<Technician>((e) => Technician.fromJson(e))
            .toList();
      } catch (e) {
        Logger().e('Error mapping topFiveTechnicians: $e');
      }

      try {
        _categories = serviceCategories
            .map<Category>((e) => Category.fromJson(e))
            .toList();
        _categories.sort((a, b) => a.id.compareTo(b.id));
      } catch (e) {
        Logger().e('Error mapping serviceCategories: $e');
      }

      try {
        _services = services.map<Service>((e) => Service.fromJson(e)).toList();
        _fiterableByCatagory = _services
            .where((service) => service.categoryId == _categories.first.id)
            .toList();
        _fiterableBySearch = _services;
      } catch (e) {
        Logger().e('Error mapping services: $e');
      }

      try {
        _reviews =
            topFiveReviews.map<Review>((e) => Review.fromJson(e)).toList();
      } catch (e) {
        Logger().e('Error mapping topFiveReviews: $e');
      }

      try {
        locations = res.data['locations']
            .map<Location>((e) => Location.fromJson(e))
            .toList();
      } catch (e) {
        Logger().e('Error mapping locations: $e');
      }

      await selectDefaultLocation();
      notifyListeners();
    } on DioException catch (e) {
      if (e.response != null) {
        Logger().e(e.response!.data);
      } else {
        Logger().e(e.message);
      }
    } catch (e) {
      Logger().e(e);
    }
  }

  int levenshteinDistance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.generate(t.length + 1, (int i) => i);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost]
            .reduce((a, b) => a < b ? a : b);
      }

      List<int> temp = v0;
      v0 = v1;
      v1 = temp;
    }

    return v0[t.length];
  }

  Future<void> selectDefaultLocation() async {
    final _location = await getCurrentLocation();
    if (_location != null) {
      final subcity = _location["subcity"];
      if (subcity != null) {
        Location? bestMatch;
        double minDistance = double.infinity;

        for (var location in locations) {
          int distance =
              levenshteinDistance(location.englishName, subcity as String);
          if (distance < minDistance) {
            minDistance = distance.toDouble();
            bestMatch = location;
          }
        }

        selectedLocation = bestMatch ?? locations.first;
      } else {
        selectedLocation = locations.first;
      }
    }
  }

  void filterServicesByCategory(int categoryId) {
    _fiterableByCatagory =
        _services.where((service) => service.categoryId == categoryId).toList();

    selectedCategoryId = categoryId;
    notifyListeners();
  }

  void filterServicesBySearch(
      {bool isCategory = false, int? categoryId, String search = ''}) {
    if (isCategory) {
      _fiterableBySearch = _services
          .where((service) => service.categoryId == categoryId)
          .toList();
    } else if (search.isNotEmpty) {
      _fiterableBySearch = _services
          .where((service) =>
              service.name.toLowerCase().contains(search.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // Sample list of FAQs
  final List<FAQ> _faqs = [
    FAQ(
      question: "What services does TanahAir Offer?",
      answer:
          "TanahAir offers a service for creating website design, illustration, icon set, and more.",
    ),
    FAQ(
      question: "Why should I choose a Design studio like TanahAir?",
      answer:
          "TanahAir provides the best service and solves customer problems with flexibility.",
    ),
    FAQ(
      question:
          "How does TanahAir create website content without knowing our Business plan?",
      answer:
          "We use collaborative tools and processes to align with the client’s vision.",
    ),
  ];

  void toggleFAQ(int index) {
    _faqs[index].isExpanded = !_faqs[index].isExpanded;
    notifyListeners();
  }

  Future<void> loadServices() async {
    // Load services from API
    try {
      final res = await apiService.getRequestWithoutToken('/services');

      final data = res.data;
      _services = data.map<Service>((e) => Service.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchTechnicianDetails(int id) async {
    isLoading = true;
    // Load AppLocalizations.of(context)!.technicianDetails from API
    try {
      final res = await apiService.getRequestWithoutToken('/technicians/$id');

      final data = res.data;
      Logger().d(data);
      _techinicianDetail = TechinicianDetail.fromJson(data);
      notifyListeners();
    } catch (e) {
      print(e);
    }
    isLoading = false;
  }

  Future<void> loadTechnicians(int id) async {
    isLoading = true;
    // Load technicians from API
    try {
      final res =
          await apiService.getRequestWithoutToken('/search/service/$id');

      final data = res.data;
      print(data);
      _technicians =
          data.map<Technician>((e) => Technician.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
    isLoading = false;
  }

  Future<void> searchTechniciansWithSchedule(
      {required int id,
      required String date,
      required String time,
      int page = 0,
      int size = 9}) async {
    isLoading = true;
    // Load technicians from API
    try {
      final query = {'date': date, 'time': time, 'page': page, 'size': size};
      final res = await apiService.getRequestByQueryWithoutToken(
          '/search/service-schedule/$id', query);

      totalPages = res.data["totalPages"];
      totalElements = res.data['totalElements'];
      Logger().d(res.data);
      final data = res.data['content'];
      _technicians =
          data.map<Technician>((e) => Technician.fromJson(e)).toList();
      notifyListeners();
    } on DioException catch (e) {
      Logger().e(e.response!.data);
    } catch (e) {
      print(e);
    }
    isLoading = false;
  }

  Future<void> filterTechnicianWithSchedule(
      Map<String, dynamic> query, int serviceId) async {
    isLoading = true;
    try {
      Logger().d(query);
      final res = await apiService.getRequestByQueryWithoutToken(
          '/search/technicians-schedule', query);

      totalPages = res.data["totalPages"];
      totalElements = res.data['totalElements'];
      Logger().d(res.data);
      final data = res.data['content'];

      _technicians =
          data.map<Technician>((e) => Technician.fromJson(e)).toList();
      notifyListeners();
    } on DioException catch (e) {
      Logger().e(e.response!.data);
    } catch (e) {
      print('error: $e');
      Logger().e(e);
    }
    isLoading = false;
  }

  Future<void> filterTechnician(
      Map<String, dynamic> query, int serviceId) async {
    isLoading = true;
    notifyListeners();
    try {
      Logger().d(query);
      final res = await apiService.getRequestByQueryWithoutToken(
          '/search/technicians/$serviceId', query);

      totalPages = res.data["totalPages"];
      totalElements = res.data['totalElements'];
      Logger().d(res.data);
      final data = res.data['content'];

      _technicians =
          data.map<Technician>((e) => Technician.fromJson(e)).toList();
    } on DioException catch (e) {
      Logger().e(e.response!.data);
    } catch (e) {
      print('error: $e');
      Logger().e(e);
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    // Load categories from API
    try {
      final res =
          await apiService.getRequestWithoutToken('/service-categories');

      final data = res.data;
      _categories = data.map<Category>((e) => Category.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchServiceQuestions(int serviceId) async {
    isLoading = true;
    // Load service questions from API
    try {
      final res = await apiService
          .getRequestWithoutToken('//search/question/$serviceId');

      final data = res.data;
      questions = List<Map<String, dynamic>>.from(data);
      Logger().d(data);
      notifyListeners();
    } catch (e) {
      Logger().e(e);
    }
    isLoading = false;
  }

  List<Dispute> get disputes => _disputes;

  void addDispute(Dispute dispute) {
    _disputes.add(dispute);
    notifyListeners();
  }

  void removeDispute(int index) {
    _disputes.removeAt(index);
    notifyListeners();
  }

  Future<List<Service>> loadSubServices(int serviceId) async {
    List<Service> subServices = [];
    try {
      print(serviceId);
      final res = await apiService
          .getRequestWithoutToken('/services/$serviceId/subservices');
      final data = res.data;
      subServices = data.map<Service>((e) => Service.fromJson(e)).toList();
    } catch (e) {
      Logger().e(e);
    }
    isLoading = false;
    return subServices;
  }
}

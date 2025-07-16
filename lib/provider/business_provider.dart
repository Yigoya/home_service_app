import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:home_service_app/models/business.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/models/business_detail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class BusinessProvider extends ChangeNotifier {
  // Business state variables
  bool _isLoading = false;
  List<dynamic> _businessServices = [];
  List<dynamic> _categories = [];
  String _error = '';

  // Business listing state
  List<Business> _businesses = [];
  int _currentPage = 0;
  int _totalPages = 0;
  int _totalElements = 0;
  String _searchQuery = '';
  int? _serviceId;
  int? _locationId;

  // Business detail state variables
  BusinessDetail? _businessDetail;
  bool _isBusinessDetailLoading = false;
  String _businessDetailError = '';
  bool _isSubmittingReview = false;
  bool _isSubmittingOrder = false;
  String _reviewError = '';
  String _orderError = '';

  // Getters
  bool get isLoading => _isLoading;
  List<dynamic> get businessServices => _businessServices;
  List<dynamic> get categories => _categories;
  String get error => _error;

  // Business listing getters
  List<Business> get businesses => _businesses;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalElements => _totalElements;
  String get searchQuery => _searchQuery;
  bool get hasMorePages => _currentPage < _totalPages - 1;

  // Business detail getters
  BusinessDetail? get businessDetail => _businessDetail;
  Map<String, dynamic>? get businessData => _businessDetail?.business.toJson();
  List<dynamic> get reviews =>
      _businessDetail?.reviews.map((r) => r.toJson()).toList() ?? [];
  List<dynamic> get services =>
      _businessDetail?.services.map((s) => s.toJson()).toList() ?? [];
  bool get isBusinessDetailLoading => _isBusinessDetailLoading;
  String get businessDetailError => _businessDetailError;
  bool get isSubmittingReview => _isSubmittingReview;
  bool get isSubmittingOrder => _isSubmittingOrder;
  String get reviewError => _reviewError;
  String get orderError => _orderError;

  // Initialize the provider with mock data for demo purposes
  Future<void> initialize() async {
    await fetchCategories();
    await fetchBusinessServices();

    // If the API endpoints are not set up yet, populate with mock data
  }

  // Fetch businesses by service ID
  Future<void> fetchBusinessesByServiceId(int serviceId,
      {int? locationId, int page = 0, String? query}) async {
    _isLoading = true;
    _serviceId = serviceId;
    _locationId = locationId;
    _searchQuery = query ?? "";

    notifyListeners();

    try {
      // Build query parameters
      final queryParams = {
        'categoryId': serviceId.toString(),
        'page': page.toString(),
        'size': '10',
        'query': query,
      };

      if (_searchQuery.isNotEmpty) {
        queryParams['query'] = _searchQuery;
      }

      if (locationId != null) {
        queryParams['locationId'] = locationId.toString();
      }

      // Make API request
      final apiService = ApiService();
      final response = await apiService.getRequestByQueryWithoutToken(
        '/businesses/search',
        queryParams,
      );
      final data = response.data;
      print(data);
      final paginatedBusinesses = PaginatedBusinesses.fromJson(data);
      if (page == 0) {
        // Replace the list if it's the first page
        _businesses = paginatedBusinesses.content;
      } else {
        // Append to the list if it's a subsequent page
        _businesses.addAll(paginatedBusinesses.content);
      }

      _currentPage = paginatedBusinesses.currentPage;
      _totalPages = paginatedBusinesses.totalPages;
      _totalElements = paginatedBusinesses.totalElements;
    } on DioException catch (e) {
      _error = 'Error connecting to server: $e';
      // For demo, use mock data if API fails
      print(e.response?.data);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more businesses (pagination)
  Future<void> loadMoreBusinesses() async {
    if (hasMorePages && !_isLoading) {
      await fetchBusinessesByServiceId(_serviceId!,
          locationId: _locationId, page: _currentPage + 1, query: _searchQuery);
    }
  }

  // Search businesses
  Future<void> searchBusinesses(String query) async {
    _searchQuery = query;
    await fetchBusinessesByServiceId(_serviceId!,
        locationId: _locationId, page: 0, query: query);
  }

  // Reset search query
  void resetSearch() {
    _searchQuery = '';
    if (_serviceId != null) {
      fetchBusinessesByServiceId(_serviceId!, locationId: _locationId, page: 0);
    }
  }

  // Populate mock businesses for a specific service (for demo)

  // Fetch categories from API
  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Replace with your actual API endpoint
      final response = await http.get(
        Uri.parse('YOUR_API_ENDPOINT/categories'),
        headers: {
          'Content-Type': 'application/json',
          // Add any authentication headers if needed
        },
      );

      if (response.statusCode == 200) {
        _categories = json.decode(response.body);
        _error = '';
      } else {
        // API call failed, but we'll use mock data instead
        // _error = 'Failed to load categories';
      }
    } catch (e) {
      // Network error, but we'll use mock data instead
      // _error = 'Error connecting to server: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch business services from API
  Future<void> fetchBusinessServices() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Replace with your actual API endpoint
      final response = await http.get(
        Uri.parse('YOUR_API_ENDPOINT/business-services'),
        headers: {
          'Content-Type': 'application/json',
          // Add any authentication headers if needed
        },
      );

      if (response.statusCode == 200) {
        _businessServices = json.decode(response.body);
        _error = '';
      } else {
        // API call failed, but we'll use mock data instead
        // _error = 'Failed to load business services';
      }
    } catch (e) {
      // Network error, but we'll use mock data instead
      // _error = 'Error connecting to server: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get category details by ID
  Map<String, dynamic>? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((category) => category['id'] == categoryId);
    } catch (e) {
      return null;
    }
  }

  // Filter business services by category
  List<dynamic> getServicesByCategory(int categoryId) {
    return _businessServices
        .where((service) => service['categoryId'] == categoryId)
        .toList();
  }

  // Search businesses by query
  List<dynamic> searchBusinessesByQuery(String query) {
    if (query.isEmpty) return _businessServices;

    final queryLower = query.toLowerCase();
    return _businessServices.where((business) {
      final name = (business['name'] ?? '').toLowerCase();
      final description = (business['description'] ?? '').toLowerCase();
      return name.contains(queryLower) || description.contains(queryLower);
    }).toList();
  }

  // Get top-rated businesses
  List<dynamic> getTopRatedBusinesses({int limit = 5}) {
    final sorted = List<dynamic>.from(_businessServices);
    sorted.sort((a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0));
    return sorted.take(limit).toList();
  }

  // Add a new business service
  Future<void> addBusinessService(Map<String, dynamic> service) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Replace with your actual API endpoint
      final response = await http.post(
        Uri.parse('YOUR_API_ENDPOINT/business-services'),
        headers: {
          'Content-Type': 'application/json',
          // Add any authentication headers if needed
        },
        body: json.encode(service),
      );

      if (response.statusCode == 201) {
        await fetchBusinessServices(); // Refresh the list
        _error = '';
      } else {
        // For demo, just add to the local list
        service['id'] = (_businessServices.length + 1).toString();
        service['createdAt'] = DateTime.now().toIso8601String().split('T')[0];
        _businessServices.add(service);
        _error = '';
      }
    } catch (e) {
      // For demo, just add to the local list
      service['id'] = (_businessServices.length + 1).toString();
      service['createdAt'] = DateTime.now().toIso8601String().split('T')[0];
      _businessServices.add(service);
      _error = '';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear any errors
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Fetch business details
  Future<void> fetchBusinessDetails(int businessId) async {
    _isBusinessDetailLoading = true;
    _businessDetailError = '';
    notifyListeners();

    try {
      final apiService = ApiService();
      print('Fetching business details for business ID: $businessId');
      final response = await apiService.getRequestWithoutToken(
        '/businesses/$businessId/details',
      );

      if (response.statusCode == 200) {
        print('Business details fetched successfully');
        print('Response data: ${response.data}');

        final data = response.data;

        // Set raw data for backward compatibility
        Map<String, dynamic> business = data['business'];
        List<dynamic> reviewsList = data['reviews'] ?? [];
        List<dynamic> servicesList = data['services'] ?? [];

        // Parse into structured data
        try {
          _businessDetail = BusinessDetail.fromJson(data);
        } catch (parseError) {
          print('Error parsing business detail: $parseError');
          // Even if we fail to parse structured data, keep the raw data
        }
      } else {
        _businessDetailError =
            'Failed to load business details. Please try again.';
      }
    } catch (e) {
      _businessDetailError = 'Error connecting to server: $e';
    } finally {
      _isBusinessDetailLoading = false;
      notifyListeners();
    }
  }

  // Submit a review
  Future<bool> submitReview({
    required int businessId,
    required int userId,
    required int rating,
    String? comment,
    List<XFile>? images,
  }) async {
    _isSubmittingReview = true;
    _reviewError = '';
    notifyListeners();

    try {
      final apiService = ApiService();

      // Create form data for multipart request
      final formData = FormData();
      formData.fields.add(MapEntry('businessId', businessId.toString()));
      formData.fields.add(MapEntry('userId', userId.toString()));
      formData.fields.add(MapEntry('rating', rating.toString()));

      if (comment != null && comment.isNotEmpty) {
        formData.fields.add(MapEntry('comment', comment));
      }

      // Add images if available
      if (images != null && images.isNotEmpty) {
        for (var i = 0; i < images.length; i++) {
          final file = await MultipartFile.fromFile(
            images[i].path,
            filename: images[i].name,
          );
          formData.files.add(MapEntry('images', file));
        }
      }

      final response = await apiService.postMultipartRequestWithoutToken(
        '/businesses/reviews',
        formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Refresh business details
        await fetchBusinessDetails(businessId);
        return true;
      } else {
        _reviewError =
            'Failed to submit review. Status code: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _reviewError = 'Error submitting review: $e';
      return false;
    } finally {
      _isSubmittingReview = false;
      notifyListeners();
    }
  }

  // Place an order directly with raw data
  Future<bool> placeOrderRaw({
    required int businessId,
    required List<Map<String, dynamic>> items,
    required int serviceLocationId,
    required int paymentMethodId,
    required DateTime scheduledDateTime,
    String? specialInstructions,
  }) async {
    _isSubmittingOrder = true;
    _orderError = '';
    notifyListeners();

    try {
      // Create order payload
      final payload = {
        'businessId': businessId,
        'items': items,
        'serviceLocationId': serviceLocationId,
        'paymentMethodId': paymentMethodId,
        'scheduledDate': scheduledDateTime.toIso8601String(),
        'specialInstructions': specialInstructions,
      };

      print('Submitting order with payload: $payload');

      final apiService = ApiService();
      final response = await apiService.postRequestWithoutToken(
        '/orders',
        payload,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        _orderError =
            'Failed to place order. Server returned: ${response.statusCode} ${response.statusMessage}';
        return false;
      }
    } catch (e) {
      _orderError = 'Error placing order: $e';
      return false;
    } finally {
      _isSubmittingOrder = false;
      notifyListeners();
    }
  }

  // Place an order using the OrderRequest class
  Future<bool> placeOrder(OrderRequest orderRequest) async {
    _isSubmittingOrder = true;
    _orderError = '';
    notifyListeners();

    try {
      final apiService = ApiService();
      final response = await apiService.postRequest(
        '/orders',
        orderRequest.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        _orderError = 'Failed to place order: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _orderError = 'Error placing order: $e';
      return false;
    } finally {
      _isSubmittingOrder = false;
      notifyListeners();
    }
  }

  // Toggle favorite status for a business
  void toggleFavorite(int businessId) {
    // This would typically involve an API call to save the favorite status
    // For now, just notify listeners to update the UI
    notifyListeners();
  }

  // Clear errors
  void clearReviewError() {
    _reviewError = '';
    notifyListeners();
  }

  void clearOrderError() {
    _orderError = '';
    notifyListeners();
  }
}

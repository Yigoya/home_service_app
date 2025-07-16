import 'package:flutter/material.dart';
import 'package:home_service_app/models/marketplace_inquiry.dart';
import 'package:home_service_app/models/marketplace_order.dart';
import 'package:home_service_app/models/marketplace_product.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:dio/dio.dart';

class MarketplaceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Products state
  List<MarketplaceProduct> _products = [];
  MarketplaceProduct? _selectedProduct;
  bool _isLoadingProducts = false;
  String _productsError = '';
  int _currentPage = 0;
  int _totalPages = 0;
  int _totalElements = 0;
  bool _hasMoreItems = false;
  
  // Search state
  String? _searchKeyword;
  String? _searchCategory;
  double? _searchMinPrice;
  double? _searchMaxPrice;
  
  // Orders and inquiries state
  List<MarketplaceOrder> _orders = [];
  List<MarketplaceInquiry> _inquiries = [];
  bool _isLoadingOrders = false;
  bool _isLoadingInquiries = false;
  String _ordersError = '';
  String _inquiriesError = '';
  
  // Order and inquiry submission state
  bool _isSubmittingOrder = false;
  bool _isSubmittingInquiry = false;
  String _orderSubmissionError = '';
  String _inquirySubmissionError = '';

  // Getters
  List<MarketplaceProduct> get products => _products;
  MarketplaceProduct? get selectedProduct => _selectedProduct;
  bool get isLoadingProducts => _isLoadingProducts;
  String get productsError => _productsError;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalElements => _totalElements;
  bool get hasMoreItems => _hasMoreItems;
  
  List<MarketplaceOrder> get orders => _orders;
  List<MarketplaceInquiry> get inquiries => _inquiries;
  bool get isLoadingOrders => _isLoadingOrders;
  bool get isLoadingInquiries => _isLoadingInquiries;
  String get ordersError => _ordersError;
  String get inquiriesError => _inquiriesError;
  
  bool get isSubmittingOrder => _isSubmittingOrder;
  bool get isSubmittingInquiry => _isSubmittingInquiry;
  String get orderSubmissionError => _orderSubmissionError;
  String get inquirySubmissionError => _inquirySubmissionError;

  // Fetch products by service ID
  Future<void> fetchProductsByServiceId(int serviceId, {int page = 0, int size = 10}) async {
    _isLoadingProducts = true;
    _productsError = '';
    notifyListeners();

    try {
      final response = await _apiService.getRequestWithoutToken(
        '/marketplace/products/by-service/$serviceId?page=$page&size=$size'
      );
      
      final data = response.data;
      final paginatedProducts = PaginatedProducts.fromJson(data);
      
      if (page == 0) {
        _products = paginatedProducts.content;
      } else {
        _products.addAll(paginatedProducts.content);
      }
      
      _currentPage = paginatedProducts.currentPage;
      _totalPages = paginatedProducts.totalPages;
      _totalElements = paginatedProducts.totalElements;
      _hasMoreItems = !paginatedProducts.last;
      
    } catch (e) {
      _productsError = 'Failed to load products: ${e.toString()}';
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }
  
  // Search products
  Future<void> searchProducts({
    String? keyword,
    String? category,
    double? minPrice,
    double? maxPrice,
    int page = 0,
    int size = 10
  }) async {
    _isLoadingProducts = true;
    _productsError = '';
    _searchKeyword = keyword;
    _searchCategory = category;
    _searchMinPrice = minPrice;
    _searchMaxPrice = maxPrice;
    notifyListeners();

    try {
      String url = '/marketplace/products?page=$page&size=$size';
      
      if (keyword != null && keyword.isNotEmpty) {
        url += '&keyword=$keyword';
      }
      
      if (category != null && category.isNotEmpty) {
        url += '&category=$category';
      }
      
      if (minPrice != null) {
        url += '&minPrice=$minPrice';
      }
      
      if (maxPrice != null) {
        url += '&maxPrice=$maxPrice';
      }
      
      final response = await _apiService.getRequestWithoutToken(url);
      
      final data = response.data;
      final paginatedProducts = PaginatedProducts.fromJson(data);
      
      if (page == 0) {
        _products = paginatedProducts.content;
      } else {
        _products.addAll(paginatedProducts.content);
      }
      
      _currentPage = paginatedProducts.currentPage;
      _totalPages = paginatedProducts.totalPages;
      _totalElements = paginatedProducts.totalElements;
      _hasMoreItems = !paginatedProducts.last;
      
    } catch (e) {
      _productsError = 'Failed to search products: ${e.toString()}';
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }
  
  // Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (_hasMoreItems && !_isLoadingProducts) {
      if (_searchKeyword != null || _searchCategory != null || _searchMinPrice != null || _searchMaxPrice != null) {
        await searchProducts(
          keyword: _searchKeyword,
          category: _searchCategory,
          minPrice: _searchMinPrice,
          maxPrice: _searchMaxPrice,
          page: _currentPage + 1
        );
      } else if (_selectedProduct != null && _selectedProduct!.serviceIds.isNotEmpty) {
        await fetchProductsByServiceId(_selectedProduct!.serviceIds.first, page: _currentPage + 1);
      }
    }
  }
  
  // Get product detail
  Future<void> getProductDetail(int productId) async {
    _isLoadingProducts = true;
    _productsError = '';
    notifyListeners();

    try {
      final response = await _apiService.getRequestWithoutToken(
        '/marketplace/products/$productId'
      );
      
      final data = response.data;
      _selectedProduct = MarketplaceProduct.fromJson(data);
      
    } catch (e) {
      _productsError = 'Failed to load product details: ${e.toString()}';
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }
  
  // Submit order
  Future<bool> submitOrder(MarketplaceOrder order) async {
    _isSubmittingOrder = true;
    _orderSubmissionError = '';
    notifyListeners();

    try {
      await _apiService.postRequest(
        '/api/v1/marketplace/orders',
        order.toJson()
      );
      
      return true;
    } catch (e) {
      _orderSubmissionError = 'Failed to submit order: ${e.toString()}';
      return false;
    } finally {
      _isSubmittingOrder = false;
      notifyListeners();
    }
  }
  
  // Submit inquiry
  Future<bool> submitInquiry(MarketplaceInquiry inquiry) async {
    _isSubmittingInquiry = true;
    _inquirySubmissionError = '';
    notifyListeners();

    try {
      await _apiService.postRequest(
        '/marketplace/inquiries',
        inquiry.toJson()
      );
      
      return true;
    } catch (e) {
      _inquirySubmissionError = 'Failed to submit inquiry: ${e.toString()}';
      return false;
    } finally {
      _isSubmittingInquiry = false;
      notifyListeners();
    }
  }
  
  // Get orders for user
  Future<void> fetchOrders(int userId) async {
    _isLoadingOrders = true;
    _ordersError = '';
    notifyListeners();

    try {
      final response = await _apiService.getRequest(
        '/api/v1/marketplace/orders/user/$userId'
      );
      
      final List<dynamic> data = response.data;
      _orders = data.map((item) => MarketplaceOrder.fromJson(item)).toList();
      
    } catch (e) {
      _ordersError = 'Failed to load orders: ${e.toString()}';
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }
  
  // Get inquiries for user
  Future<void> fetchInquiries(int userId) async {
    _isLoadingInquiries = true;
    _inquiriesError = '';
    notifyListeners();

    try {
      final response = await _apiService.getRequest(
        '/marketplace/inquiries/user/$userId'
      );
      
      final List<dynamic> data = response.data;
      _inquiries = data.map((item) => MarketplaceInquiry.fromJson(item)).toList();
      
    } catch (e) {
      _inquiriesError = 'Failed to load inquiries: ${e.toString()}';
    } finally {
      _isLoadingInquiries = false;
      notifyListeners();
    }
  }
  
  // Reset selected product
  void resetSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }
}
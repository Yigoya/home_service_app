import 'package:flutter/material.dart';
import '../models/promotion.dart';
import '../services/api_service.dart';

class PromotionProvider extends ChangeNotifier {
  List<Promotion> _promotions = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Promotion> get promotions => _promotions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasPromotions => _promotions.isNotEmpty;

  // Fetch featured promotions from API
  Future<void> fetchFeaturedPromotions() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await ApiService()
          .getRequest('/businesses/promotions/public/featured');

      if (response != null &&
          response.data != null &&
          response.data['content'] != null) {
        final List<dynamic> promotionsData = response.data['content'];
        final List<Promotion> promotions = promotionsData
            .map((json) => Promotion.fromJson(json))
            .where((promotion) =>
                promotion.isActiveNow) // Only show active promotions
            .toList();

        _setPromotions(promotions);
      } else {
        _setPromotions([]);
      }
    } catch (e) {
      _setError('Failed to fetch promotions: $e');
      _setPromotions([]);
    } finally {
      _setLoading(false);
    }
  }

  // Refresh promotions
  Future<void> refreshPromotions() async {
    await fetchFeaturedPromotions();
  }

  // Clear promotions
  void clearPromotions() {
    _setPromotions([]);
  }

  // Private methods to update state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setPromotions(List<Promotion> promotions) {
    _promotions = promotions;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/utils/functions.dart';
import 'package:logger/web.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PaymentProvider with ChangeNotifier {
  final Dio _dio = Dio();
  bool _isLoading = false;

  List<Map<String, dynamic>> _banks = [
    {
      'name': 'Telebirr',
      'image': 'assets/images/TeleBirr Logo.png',
      'code': '855'
    },
    {
      'name': 'Dashen',
      'image': 'assets/images/Dashen Bank Logo.png',
      'code': '880'
    },
    {
      'name': 'CBEBirr',
      'image': 'assets/images/CBE Birr ( No background ) Logo.png',
      'code': '946'
    },
    {
      'name': 'Hibret',
      'image': 'assets/images/Hibret Bank ( No text ) Logo.png',
      'code': '534'
    },
    {
      'name': 'Bank of Abyssinia',
      'image': 'assets/images/Bank of Abyssinia Logo.png',
      'code': '347'
    },
    {
      'name': 'Awash',
      'image': 'assets/images/Awash International Bank ( No text ) Logo.png',
      'code': '656'
    }
  ];
  String? _selectedBank;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get banks => _banks;
  String? get selectedBank => _selectedBank;

  // Set selected bank
  void setSelectedBank(String? bankCode) {
    _selectedBank = bankCode;
    notifyListeners();
  }

  // Fetch banks
  Future<void> fetchBanks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get(
        '${ApiService.API_URL}/payment/banks',
      );

      _banks = List<Map<String, dynamic>>.from(response.data);
      Logger().i('Banks: $_banks');
    } on DioException catch (e) {
      if (e.response != null) {
        Logger().e('Error: ${e.response!.data}');
      } else {
        Logger().e('Error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Initialize payment
  Future<String> initializePayment({
    required double amount,
    required String email,
    required String firstName,
    required String lastName,
    required BuildContext context,
  }) async {
    if (_selectedBank == null) {
      showTopMessage(context, AppLocalizations.of(context)!.pleaseSelectABank,
          isSuccess: false);
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.post(
        '${ApiService.API_URL}/payment/initialize',
        data: {
          'amount': amount,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'bankCode': _selectedBank,
        },
      );
      final checkoutUrl = response.data;
      return checkoutUrl;
    } on DioException catch (e) {
      Logger().e('Error: $e');
      return '';
    } catch (e) {
      Logger().e('Error: $e');
      return '';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

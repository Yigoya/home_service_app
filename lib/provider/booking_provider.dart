import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:home_service_app/screens/booking/buy_coins_page.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/utils/functions.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BookingProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final Map<int, String> _answers = {};
  final List<Map<String, dynamic>> _answersToSubmit = [];
  Map<int, String> get answers => _answers;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DateTime? get selectedDate => _selectedDate;
  TimeOfDay? get selectedTime => _selectedTime;
  String? selectedSubCity;
  String? selectedWereda;
  Map<String, dynamic> bookingData = {};
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setSelectedTime(TimeOfDay time) {
    _selectedTime = time;
    notifyListeners();
  }

  void setSelectedSubCity(String? subCity) {
    selectedSubCity = subCity;
    notifyListeners();
  }

  void setSelectedWereda(String? wereda) {
    selectedWereda = wereda;
    notifyListeners();
  }

  void updateAnswer(int questionId, String response) {
    _answers[questionId] = response;
    _answersToSubmit.add({"questionId": questionId, "response": response});
    notifyListeners();
  }

  Future<bool> bookService(
      Map<String, dynamic> data, BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    Logger().d(_selectedDate);
    try {
      data['scheduledDate'] = _selectedDate != null && _selectedTime != null
          ? DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime(
              _selectedDate!.year,
              _selectedDate!.month,
              _selectedDate!.day,
              _selectedTime!.hour,
              _selectedTime!.minute))
          : DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now());
      data['subcity'] = selectedSubCity;
      data['wereda'] = selectedWereda;
      data['city'] = 'Addis Ababa';

      Logger().d(data);
      final response = await _apiService.postRequest('/booking/request', data);
      Logger().d(response.data);

      final bookingId = response.data['bookingId'];
      final answerData = {
        "bookingId": bookingId,
        "customerId": data['customerId'],
        "answers": _answers.entries.map((item) {
          return {
            "questionId": item.key,
            "response": item.value,
          };
        }).toList(),
      };
      Logger().d(answerData);
      if (answerData["answers"].length > 0) {
        final answerResponse =
            await _apiService.postRequest('/booking/answer', answerData);
        Logger().d(answerResponse.data);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (dioError) {
      _isLoading = false;
      notifyListeners();
      Logger().e(dioError.response!.data['details']);
      if (dioError.response!.data['details'][0] ==
          "Insufficient coins for booking") {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const BuyCoinsPage()));
        return false;
      }
      showTopMessage(context, dioError.response!.data['details'].join(', '),
          isSuccess: false);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error: $e');
    }
    return false;
  }

  Future<void> updateBookingStatus(int bookingId, String status) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = {
        "bookingId": bookingId,
        "status": status,
      };
      Logger().d(data);
      final response =
          await _apiService.putRequest('/booking/update-status', data);
      Logger().d(response.data);
    } on DioException catch (dioError) {
      // Handle Dio specific errors
      print('Dio error: ${dioError.message}');
    } catch (e) {
      // Handle other errors
      print('Error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateBooking(int bookingId, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response =
          await _apiService.putRequest('/booking/$bookingId', data);
      Logger().d(response.data);
    } on DioException catch (dioError) {
      // Handle Dio specific errors
      Logger().e('Dio error: ${dioError.response?.data}');
    } catch (e) {
      // Handle other errors
      Logger().e('Error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> submitReview(int bookingId, int rating, String review) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = {
        "bookingId": bookingId,
        'rating': rating,
        "review": review,
      };
      final response = await _apiService.postRequest('/review', data);
      Logger().d(response.data);
    } on DioException catch (dioError) {
      // Handle Dio specific errors
      Logger().e('Dio error: ${dioError.response?.data}');
    } catch (e) {
      // Handle other errors
      Logger().e('Error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchSingleBooking(int bookingId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.getRequest('/bookings/$bookingId');
      bookingData = response.data;

      notifyListeners();
    } on DioException catch (dioError) {
      // Handle Dio specific errors
      Logger().e('Dio error: ${dioError.response?.data}');
    } catch (e) {
      // Handle other errors
      Logger().e('Error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }
}

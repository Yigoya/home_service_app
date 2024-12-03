import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:logger/web.dart';

class FormProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController disputeDescriptionController =
      TextEditingController();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Example: Function to handle form submission
  Future<void> submitContactForm() async {
    // Collect data
    final name = nameController.text;
    final email = emailController.text;
    final phone = phoneController.text;
    final message = messageController.text;

    try {
      _isLoading = true;
      notifyListeners();
      final response = await _apiService.postRequest(
        '/contact-us',
        {
          'name': name,
          'email': email,
          'phoneNumber': phone,
          'message': message,
        },
      );

      print("Submitting Contact Form with data:");
      print("Name: $name, Email: $email, Phone: $phone, Message: $message");
      Logger().d(response.data);
      // Clear fields after submission
      nameController.clear();
      emailController.clear();
      phoneController.clear();
      messageController.clear();
    } on DioException catch (e) {
      print(e.response!.data);
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitDisputeForm(int bookingId) async {
    // Collect data
    final reason = reasonController.text;
    final description = disputeDescriptionController.text;

    try {
      _isLoading = true;
      notifyListeners();
      final response = await _apiService.postRequest(
        '/dispute',
        {
          'bookingId': bookingId,
          'title': reason,
          'description': description,
        },
      );

      print("Submitting Dispute Form with data:");
      print("Reason: $reason, Description: $description");
      Logger().d(response.data);
      // Clear fields after submission
      reasonController.clear();
      disputeDescriptionController.clear();
    } on DioException catch (e) {
      print(e.response!.data);
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Send data to the backend or handle it as needed
    print("Submitting Dispute Form with data:");
    print("Reason: $reason, Description: $description");

    // Clear fields after submission
    reasonController.clear();
    disputeDescriptionController.clear();

    notifyListeners();
  }
}

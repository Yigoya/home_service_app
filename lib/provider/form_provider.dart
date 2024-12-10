import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/utils/functions.dart';
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

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Your form has been submitted successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Example: Function to handle form submission
  Future<void> submitContactForm(BuildContext context) async {
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
      showTopMessage(context, 'Your form has been submitted successfully.');
      nameController.clear();
      emailController.clear();
      phoneController.clear();
      messageController.clear();
    } on DioException catch (e) {
      print(e.response!.data);
      showTopMessage(context, 'Network Error happened', isSuccess: false);
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitDisputeForm(int bookingId, BuildContext context) async {
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
      showTopMessage(context, 'Your form has been submitted successfully.');
      reasonController.clear();
      disputeDescriptionController.clear();
    } on DioException catch (e) {
      print(e.response!.data);
      showTopMessage(context, 'Network Error happened', isSuccess: false);
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

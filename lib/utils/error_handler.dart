import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:home_service_app/utils/exceptions.dart';
import 'package:home_service_app/l10n/app_localizations.dart';

class ErrorHandler {
  static void handleException(Exception e, BuildContext context) {
    String errorMessage = "An unexpected error occurred";

    if (e is NetworkException) {
      errorMessage = e.message;
    } else if (e is ServerException) {
      errorMessage = e.message;
    } else if (e is ValidationException) {
      errorMessage = e.message;
    } else if (e is UnknownException) {
      errorMessage = e.message;
    } else {
      errorMessage = "An unknown error has occurred.";
    }

    // Log the error to console for debugging
    log("Error: ${e.toString()}");

    // Display the error to the user
    _showErrorDialog(context, errorMessage);
  }

  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }
}

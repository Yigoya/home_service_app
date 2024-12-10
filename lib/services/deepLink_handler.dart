import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:home_service_app/main.dart';
import 'package:home_service_app/screens/auth/forget_password_page.dart';
import 'package:home_service_app/screens/auth/upload_proof_page.dart';
import 'package:home_service_app/screens/dispute_page.dart';
import 'package:logger/logger.dart';

/// Provides methods to manage dynamic links.
final class DynamicLinkHandler {
  DynamicLinkHandler._();

  static final instance = DynamicLinkHandler._();

  final _appLinks = AppLinks();

  /// Initializes the [DynamicLinkHandler].
  Future<void> initialize(BuildContext context) async {
    _appLinks.uriLinkStream
        .listen((Uri uri) => _handleLinkData(uri, context))
        .onError((error) {
      log('$error', name: 'Dynamic Link Handler');
    });
    _checkInitialLink(context);
  }

  /// Handle navigation if initial link is found on app start.
  Future<void> _checkInitialLink(BuildContext context) async {
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleLinkData(initialLink, context);
    }
  }

  /// Handles the link navigation Dynamic Links.
  void _handleLinkData(Uri data, BuildContext context) {
    final queryParams = data.queryParameters;
    Logger().d(data.toString() + 'Dynamic Link Handler');
    if (data.path == '/products') {
      final productId = queryParams['id'];
      final productTitle = queryParams['title'];
      if (productId != null && productTitle != null) {
        // Navigate to the product page
        print('Product ID: $productId, Product Title: $productTitle');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DisputePage(bookingId: 1),
          ),
        );
      }
    } else if (data.path == '/verify') {
      final token = queryParams['token'];
      if (token != null) {
        // Verify the token
        Logger().d('Token: $token');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadProofPage(
              token: token,
            ),
          ),
        );
      }
    } else if (data.path == '/reset-password') {
      final token = queryParams['token'];
      if (token != null) {
        print('Token: $token');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ForgotPasswordPage(
              token: token,
            ),
          ),
        );
      }
    }
    if (queryParams.isNotEmpty) {
      // Perform navigation as needed.
      // Get required data by [queryParams]
    }
  }

  /// Provides the short url for your dynamic link.
  Future<String> createProductLink({
    required int id,
    required String title,
  }) async {
    // Call Rest API if link needs to be generated from backend.
    return 'https://example.com/products?id=$id&title=$title';
  }
}

import 'package:flutter/material.dart';
import '../models/subscription.dart';

class SubscriptionProvider with ChangeNotifier {
  Subscription? _selectedSubscription;

  Subscription? get selectedSubscription => _selectedSubscription;

  // Sample subscription packages based on client requirements
  final List<Subscription> _subscriptions = [
    Subscription(
      id: 'free',
      name: 'Free Membership',
      price: 0.0,
      duration: 'N/A',
      features: [
        'Access State Tenders for Free (Website Only)',
        'Download Tender Document for Free (Website Only)',
        'Create a Free Business Listing',
      ],
    ),
    Subscription(
      id: 'monthly_1',
      name: '1 Month',
      price: 500.0,
      duration: '1 Month',
      features: [
        'Unlimited Tender Access',
        'Tender Notification via Email, WhatsApp, Telegram',
        'Online Dashboard Access',
        'Access to Archive Tenders',
        'Unlimited Keywords',
        'Personal Dashboard',
        'Advanced Search by Category, Location, etc.',
      ],
    ),
    Subscription(
      id: 'monthly_3',
      name: '3 Months',
      price: 1000.0,
      duration: '3 Months',
      features: [
        'Unlimited Tender Access',
        'Tender Notification via Email, WhatsApp, Telegram',
        'Online Dashboard Access',
        'Access to Archive Tenders',
        'Unlimited Keywords',
        'Personal Dashboard',
        'Advanced Search by Category, Location, etc.',
      ],
    ),
    Subscription(
      id: 'monthly_6',
      name: '6 Months',
      price: 1400.0,
      duration: '6 Months',
      features: [
        'Unlimited Tender Access',
        'Tender Notification via Email, WhatsApp, Telegram',
        'Online Dashboard Access',
        'Access to Archive Tenders',
        'Unlimited Keywords',
        'Personal Dashboard',
        'Advanced Search by Category, Location, etc.',
      ],
    ),
    Subscription(
      id: 'yearly',
      name: '1 Year',
      price: 2000.0,
      duration: '12 Months',
      features: [
        'Unlimited Tender Access',
        'Tender Notification via Email, WhatsApp, Telegram',
        'Online Dashboard Access',
        'Access to Archive Tenders',
        'Unlimited Keywords',
        'Personal Dashboard',
        'Advanced Search by Category, Location, etc.',
      ],
    ),
  ];

  List<Subscription> get subscriptions => _subscriptions;

  void selectSubscription(Subscription subscription) {
    _selectedSubscription = subscription;
    notifyListeners();
  }

  Future<bool> processSubscriptionPayment() async {
    // Simulate payment processing (replace with actual payment gateway integration, e.g., Flutterwave, PayPal)
    await Future.delayed(const Duration(seconds: 2));
    return true; // Return true for success, false for failure
  }
}

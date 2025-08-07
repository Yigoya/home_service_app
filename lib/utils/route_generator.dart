import 'package:flutter/material.dart';
import 'package:home_service_app/models/booking.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/models/technician.dart';
import 'package:home_service_app/screens/auth/forget_password_page.dart';
import 'package:home_service_app/screens/auth/login.dart';
import 'package:home_service_app/screens/auth/signup.dart';
import 'package:home_service_app/screens/auth/technicain_regiteration.dart';
import 'package:home_service_app/screens/auth/upload_proof.dart';
import 'package:home_service_app/screens/auth/verification_wait_screen.dart';
import 'package:home_service_app/screens/auth/verifyemail_page.dart';
import 'package:home_service_app/screens/booking/booking.dart';
import 'package:home_service_app/screens/business/add_business_page.dart';
import 'package:home_service_app/screens/business/business_home_page.dart';
import 'package:home_service_app/screens/business/business_list_page.dart';
import 'package:home_service_app/screens/business/business_search_page.dart';
import 'package:home_service_app/screens/business/business_subcategory_page.dart';
import 'package:home_service_app/screens/business/business_top_rated_page.dart';
import 'package:home_service_app/screens/home/questionnaire_page.dart';
import 'package:home_service_app/screens/booking/update_booking.dart';
import 'package:home_service_app/screens/contact_page.dart';
import 'package:home_service_app/screens/detail_booking.dart';
import 'package:home_service_app/screens/dispute_page.dart';
import 'package:home_service_app/screens/disputelist_page.dart';
import 'package:home_service_app/screens/home/home.dart';
import 'package:home_service_app/screens/job/main_screen.dart';
import 'package:home_service_app/screens/job/onboarding_screen.dart';
import 'package:home_service_app/screens/marketplace/marketplace_home_page.dart';
import 'package:home_service_app/screens/marketplace/marketplace_product_detail.dart';
import 'package:home_service_app/screens/marketplace/marketplace_product_list.dart';
import 'package:home_service_app/screens/marketplace/marketplace_search_page.dart';
import 'package:home_service_app/screens/notification.dart';
import 'package:home_service_app/screens/profile/customer_profile_page.dart';
import 'package:home_service_app/screens/profile/technician_detail_page.dart';
import 'package:home_service_app/screens/profile/technician_profile_page.dart';
import 'package:home_service_app/screens/tender/subscription_page.dart';
import 'package:home_service_app/screens/business/business_detail_page.dart';
// Import other pages here

class RouteGenerator {
  static const String homePage = '/';
  static const String loginPage = '/login';
  static const String signupPage = '/signup';
  static const String technicianRegisterPage = '/register_technician';
  static const String searchPage = '/search';
  static const String bookingPage = '/booking';
  static const String customerProfilePage = '/customer_profile';
  static const String technicianProfilePage = '/technician_profile';
  static const String technicianDetailPage = '/technician_detail';
  static const String verificationWaitPage = '/verification_wait';
  static const String verificationPage = '/verification';
  static const String contactPage = '/contact';
  static const String disputeListPage = '/disputelist';
  static const String disputePage = '/dispute';
  static const String updateBookingPage = '/update_booking';
  static const String questionairePage = '/questionaire';
  static const String notificationPage = '/notification';
  static const String detailBookingPage = '/detail_booking';
  static const String forgotPasswordPage = '/forgot_password';
  static const String subscriptionPage = '/subscription';
  static const String jobPage = '/main-screen';
  static const String businessHomePage = '/business_home';
  static const String businessListingPage = '/business_listing';
  static const String businessDetailPage = '/business_detail';
  static const String businessSubcategoryPage = '/business_subcategory';
  static const String businessSearchPage = '/business_search';
  static const String businessTopRatedPage = '/business_top_rated';
  static const String addBusinessPage = '/add_business';
  static const String marketplaceHomePage = '/marketplace_home';
  static const String marketplaceProductListPage = '/marketplace_product_list';
  static const String marketplaceProductDetailPage = '/marketplace_product_detail';
  static const String marketplaceSearchPage = '/marketplace_search';

  // static const String resetPasswordPage = '/reset_password';
  // static const String settingsPage = '/settings';
  // static const String aboutPage = '/about';
  // static const String faqPage = '/faq';
  // static const String termsPage = '/terms';
  static const String uploadProofPage = '/upload_proof';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homePage:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case loginPage:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signupPage:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case technicianRegisterPage:
        return MaterialPageRoute(
            builder: (_) => const TechnicianRegistrationPage());

      case bookingPage:
        return MaterialPageRoute(
          builder: (_) => BookingPage(
            technician: (settings.arguments
                as Map<String, dynamic>)['technician'] as Technician,
            service: (settings.arguments as Map<String, dynamic>)['service']
                as Service,
          ),
        );
      case customerProfilePage:
        return MaterialPageRoute(builder: (_) => const CustomerProfilePage());
      case technicianProfilePage:
        return MaterialPageRoute(builder: (_) => const TechnicianProfilePage());
      case technicianDetailPage:
        return MaterialPageRoute(
          builder: (_) =>
              TechncianDetailPage(technicianId: settings.arguments as int),
        );
      case verificationWaitPage:
        return MaterialPageRoute(
          builder: (_) => const VerificationWaitPage(),
        );

      case verificationPage:
        return MaterialPageRoute(
          builder: (_) => const VerifyEmailPage(),
        );

      case uploadProofPage:
        return MaterialPageRoute(
          builder: (_) => UploadProofPagee(),
        );
      case contactPage:
        return MaterialPageRoute(
          builder: (_) => const ContactPage(),
        );
      case disputeListPage:
        return MaterialPageRoute(
          builder: (_) => const DisputeListPage(),
        );
      case disputePage:
        return MaterialPageRoute(
          builder: (_) => DisputePage(bookingId: settings.arguments as int),
        );
      case updateBookingPage:
        return MaterialPageRoute(
          builder: (_) =>
              UpdateBookingPage(booking: settings.arguments as Booking),
        );
      case questionairePage:
        return MaterialPageRoute(
          builder: (_) =>
              QuestionnairePage(service: settings.arguments as Service),
        );
      case notificationPage:
        return MaterialPageRoute(
          builder: (_) => const NotificationsPage(),
        );
      case detailBookingPage:
        return MaterialPageRoute(
          builder: (_) => const BookingDetailsPage(),
        );
      case forgotPasswordPage:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordPage(),
        );
      case subscriptionPage:
        return MaterialPageRoute(
          builder: (_) => const SubscriptionPage(),
        );
      case jobPage:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );
      case businessHomePage:
        return MaterialPageRoute(builder: (_) => const BusinessHomePage());
      case businessDetailPage:
        return MaterialPageRoute(
          builder: (_) => BusinessDetailPage(
              businessId: (settings.arguments as Map<String, dynamic>)['id']),
        );
      case businessSubcategoryPage:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BusinessSubcategoryPage(
            categoryId: args['categoryId'],
            categoryName: args['categoryName'],
          ),
        );
      // case businessSearchPage:
      //   return MaterialPageRoute(
      //     builder: (_) => const BusinessSearchPage(),
      //   );
      case businessTopRatedPage:
        return MaterialPageRoute(
          builder: (_) => const BusinessTopRatedPage(),
        );
      case addBusinessPage:
        return MaterialPageRoute(builder: (_) => const AddBusinessPage());
        
      // Marketplace routes
      case marketplaceHomePage:
        return MaterialPageRoute(builder: (_) => const MarketplaceHomePage());
      case marketplaceProductListPage:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => MarketplaceProductList(
            category: args?['category'],
            serviceId: args?['serviceId'],
          ),
        );
      case marketplaceProductDetailPage:
        return MaterialPageRoute(
          builder: (_) => MarketplaceProductDetail(
            productId: settings.arguments as int,
          ),
        );
      case marketplaceSearchPage:
        return MaterialPageRoute(
          builder: (_) => const MarketplaceSearchPage(),
        );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')),
      ),
    );
  }
}

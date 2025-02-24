import 'package:url_launcher/url_launcher.dart';

class ContactService {
  /// Launches the phone dialer with the provided phone number.
  static Future<void> makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  /// Opens WhatsApp chat with the given phone number and optional message.
  ///
  /// The phone number should be in international format without any + sign or spaces.
  static Future<void> openWhatsApp(String phoneNumber,
      {String? message}) async {
    // Construct the WhatsApp URL.
    final String urlString = "https://wa.me/$phoneNumber" +
        (message != null && message.isNotEmpty
            ? "?text=${Uri.encodeComponent(message)}"
            : "");
    final Uri launchUri = Uri.parse(urlString);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch WhatsApp for $phoneNumber';
    }
  }
}

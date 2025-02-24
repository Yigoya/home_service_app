class TenderUser {
  final String firstName;
  final String lastName;
  final String emailOrMobile;
  final String tenderReceiveVia; // Email, WhatsApp, or Telegram
  final String contactId; // WhatsApp address or Telegram handle
  final String category;
  final String password;
  final String? companyName; // Optional
  final String? tinNumber; // Optional

  TenderUser({
    required this.firstName,
    required this.lastName,
    required this.emailOrMobile,
    required this.tenderReceiveVia,
    required this.contactId,
    required this.category,
    required this.password,
    this.companyName,
    this.tinNumber,
  });
}

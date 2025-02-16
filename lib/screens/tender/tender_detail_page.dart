import 'package:flutter/material.dart';
import 'package:home_service_app/models/tender.dart';
import 'package:home_service_app/provider/tender_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/auth/login.dart';
import 'package:home_service_app/screens/tender/component/login_blur.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/services/document_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TenderDetailPage extends StatefulWidget {
  final int tenderId;

  const TenderDetailPage({Key? key, required this.tenderId}) : super(key: key);

  @override
  State<TenderDetailPage> createState() => _TenderDetailPageState();
}

class _TenderDetailPageState extends State<TenderDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<TenderProvider>(context, listen: false)
        .fetchTender(widget.tenderId));
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Tender Details",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Consumer<TenderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(
                child: Text(provider.errorMessage,
                    style: const TextStyle(color: Colors.red)));
          }

          final tender = provider.tender;
          if (tender == null) {
            return const Center(child: Text("No tender data available."));
          }

          return LoginBlur(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(tender),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          _buildDetailRow(
                              Icons.location_on, "Location", tender.location),
                          _buildDetailRow(Icons.date_range, "Closing Date",
                              _formatDate(tender.closingDate)),
                          if (user != null)
                            _buildDetailRow(Icons.contact_mail, "Contact Info",
                                tender.contactInfo ?? ''),
                          _buildDetailRow(Icons.info_outline, "Status",
                              _formatStatus(tender.status)),
                          tender.description != null && user != null
                              ? _buildDescription(tender.description!)
                              : SizedBox(
                                  height: 52,
                                )
                        ],
                      ),
                    ),
                    if (tender.document != null && user != null)
                      _buildDownloadButton(
                          '${ApiService.API_URL_FILE}${tender.document}',
                          tender.document!,
                          context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Tender tender) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tender.title,
            style: const TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Service ID: ${tender.serviceId}",
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
              child:
                  Text(value, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Description",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(
      String documentUrl, String fileName, BuildContext context) {
    final documentService = DocumentService();

    return GestureDetector(
      onTap: () async {
        String? filePath = await documentService.downloadDocument(
            documentUrl, fileName, context);
        if (filePath != null) {
          await documentService.openDocument(filePath);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.download, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Download & Open Document",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return "N/A";
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat("dd MMM yyyy, hh:mm a").format(parsedDate);
    } catch (e) {
      return "Invalid Date";
    }
  }

  String _formatStatus(String status) {
    switch (status.toUpperCase()) {
      case "OPEN":
        return "🟢 Open";
      case "CLOSED":
        return "🔴 Closed";
      default:
        return "⚪ Unknown";
    }
  }
}

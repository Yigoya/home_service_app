import 'package:flutter/material.dart';
import 'package:home_service_app/models/tender.dart';
import 'package:home_service_app/provider/tender_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/tender/component/login_blur.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/services/document_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class TenderDetailPage extends StatefulWidget {
  final int tenderId;

  const TenderDetailPage({Key? key, required this.tenderId}) : super(key: key);

  @override
  State<TenderDetailPage> createState() => _TenderDetailPageState();
}

class _TenderDetailPageState extends State<TenderDetailPage> {
  final GlobalKey _widgetKey = GlobalKey();
  Size? _widgetSize;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<TenderProvider>(context, listen: false)
        .fetchTender(widget.tenderId));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getWidgetSize();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getWidgetSize();
  }

  void _shareContent() {
    String shareableLink = "${ApiService.API_URL}/details/${widget.tenderId}";

    Share.share("Check this out: $shareableLink");
  }

  void _getWidgetSize() {
    final RenderBox? renderBox =
        _widgetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      setState(() {
        _widgetSize = renderBox.size;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    print(_widgetSize?.height);
    print("Widget Size: $_widgetSize");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Tender Details",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: Theme.of(context).secondaryHeaderColor,
              size: 26,
            ),
            onPressed: () {
              _shareContent();
            },
          ),
        ],
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
            getSize: _getWidgetSize,
            size: _widgetSize,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                key: _widgetKey,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(tender),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 12),
                        Text("Posted on: ${_formatDate(tender.closingDate)}",
                            style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text("Expiry Date: ${_formatDate(tender.closingDate)}",
                            style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                          "Category: ${tender.categoryName}",
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text("Location: ${tender.location}",
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text("Status: ${_formatStatus(tender.status)}",
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                            "Question Answer Deadline: ${_formatDate(tender.questionDeadline)}",
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  if (tender.description != null && user != null)
                    _buildDescription(tender.description!),
                  if (tender.document != null && user != null)
                    _buildDownloadButton(
                        '${ApiService.API_URL_FILE}${tender.document}',
                        tender.document!,
                        context),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Container();
                    },
                  )
                ],
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
        color: Theme.of(context).secondaryHeaderColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(8)),
      ),
      child: Text(
        tender.title,
        style: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
      width: double.infinity,
      height: 216,
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            ),
            child: Text(
              "Organization Details, Notice Details and Documents",
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              description,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
          color: Theme.of(context).secondaryHeaderColor,
          borderRadius: BorderRadius.circular(8),
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
    if (date == null) return "Not specified";
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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:home_service_app/provider/agency_provider.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/services/contact_service.dart';
import 'package:provider/provider.dart';

class AgencyDetailPage extends StatefulWidget {
  final int agencyId;

  const AgencyDetailPage({super.key, required this.agencyId});

  @override
  State<AgencyDetailPage> createState() => _AgencyDetailPageState();
}

class _AgencyDetailPageState extends State<AgencyDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<AgencyProvider>(context, listen: false)
          .fetchAgencyDetails(widget.agencyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Agency Details",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AgencyProvider>(
        builder: (context, agencyProvider, child) {
          if (agencyProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (agencyProvider.agency == null) {
            return Center(child: Text("No data available."));
          }

          final agency = agencyProvider.agency!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // margin: const EdgeInsets.symmetric(vertical: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300, width: 2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: agency.image.isNotEmpty
                                ? Image.network(
                                    '${ApiService.API_URL_FILE}${agency.image}',
                                    height: 120,
                                    width: 120,
                                    fit: BoxFit.cover)
                                : Image.asset('assets/images/placeholder.png',
                                    height: 150, width: 80, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                agency.businessName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 2),

                              // 2) Rating row: "4.9 ★ (462 Ratings)"
                              Row(
                                children: [
                                  Text(
                                    "5",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.star,
                                      color: Colors.orange, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    "(21 Ratings)",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                agency.address,
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600),
                              ),

                              const SizedBox(height: 4),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 108,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 4,
                          children: [
                            _infoChip("3 Years in Business"),
                            _infoChip("Open 24 Hrs"),
                            _infoChip("34 Enquiries"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              ContactService.makeCall(agency.phone);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[700],
                                border: Border.all(color: Colors.blue[700]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.call,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Call Now',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ContactService.openWhatsApp(agency.phone,
                                  message:
                                      "Hello, I am interested in your services.");
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.only(left: 4, right: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black54),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    "assets/images/whatsapp1.png",
                                    width: 34,
                                    height: 34,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "WhatsApp",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "About Us",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        agency.description,
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Services We Offer",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      if (agency.services == null || agency.services!.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("No services available",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                        ),
                      ...?agency.services?.map((service) => Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: Text(
                              service.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )),

                      SizedBox(height: 20),

                      // Reviews
                      // Text("Customer Reviews",
                      //     style: TextStyle(
                      //         fontSize: 18, fontWeight: FontWeight.bold)),
                      // ...agency.reviews.map((review) => Card(
                      //       margin: EdgeInsets.symmetric(vertical: 5),
                      //       child: ListTile(
                      //         leading: Icon(Icons.person),
                      //         title: Text(review["name"]!),
                      //         subtitle: Text(review["comment"]!),
                      //       ),
                      //     )),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600),
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:home_service_app/models/agency.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/provider/agency_provider.dart';
import 'package:home_service_app/screens/agency/agency_detail_page.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/services/contact_service.dart';
import 'package:provider/provider.dart';

class AgencyListScreen extends StatefulWidget {
  final Service service;
  const AgencyListScreen({Key? key, required this.service}) : super(key: key);

  @override
  State<AgencyListScreen> createState() => _AgencyListScreenState();
}

class _AgencyListScreenState extends State<AgencyListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<AgencyProvider>(context, listen: false)
          .fetchAgencies(widget.service.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final agencyProvider = Provider.of<AgencyProvider>(context);
    final agencies = agencyProvider.filteredAgencies;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Agencies",
            style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // 1) Row of filter / sort / quick references
          // _buildFilterRow(),
          // 2) Results count text
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by name",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                Provider.of<AgencyProvider>(context, listen: false)
                    .searchAgenciesByName(value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                // Example from screenshot
                "${agencies.length} Results for your search",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // 3) Main content
          Expanded(
            child: agencyProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : agencyProvider.errorMessage.isNotEmpty
                    ? Center(child: Text(agencyProvider.errorMessage))
                    : ListView.builder(
                        itemCount: agencies.length,
                        itemBuilder: (context, index) {
                          final agency = agencies[index];
                          return _AgencyCard(agency: agency);
                        },
                      ),
          ),
        ],
      ),
      // 4) Floating button for "Map"
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement map view
        },
        icon: const Icon(Icons.map),
        label: const Text("Map"),
      ),
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterButton(label: "Sort By"),
          const SizedBox(width: 8),
          _FilterButton(label: "Top Rated"),
          const SizedBox(width: 8),
          _FilterButton(label: "Quick Response"),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  const _FilterButton({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.blueAccent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () {
        // TODO: handle filter
      },
      child: Text(label),
    );
  }
}

class _AgencyCard extends StatelessWidget {
  final Agency agency;
  const _AgencyCard({Key? key, required this.agency}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('${ApiService.API_URL_FILE}${agency.image}');
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AgencyDetailPage(agencyId: agency.id),
          ),
        );
      },
      child: Container(
        // margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                        const Icon(Icons.star, color: Colors.orange, size: 16),
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
                    SizedBox(
                      width: min(MediaQuery.of(context).size.width - 160, 200),
                      child: Text(
                        agency.description,
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      border: Border.all(color: Colors.blue[700]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.call, color: Colors.white, size: 20),
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
                        message: "Hello, I am interested in your services.");
                  },
                  child: Container(
                    padding: const EdgeInsets.only(left: 4, right: 12),
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
          ],
        ),
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

import 'package:flutter/material.dart';
import 'package:home_service_app/models/tender.dart';
import 'package:home_service_app/screens/tender/tender_detail_page.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:share_plus/share_plus.dart';

class TenderCard extends StatelessWidget {
  final Tender tender;
  final bool isLast;

  const TenderCard({super.key, required this.tender, this.isLast = false});

  void _shareContent() {
    String shareableLink = "${ApiService.API_URL}/details/${tender.id}";

    Share.share("Check this out: $shareableLink");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            left: BorderSide(
              color: Colors.grey[300]!,
              width: 1.5,
            ),
            right: BorderSide(
              color: Colors.grey[300]!,
              width: 1.5,
            ),
            bottom: isLast
                ? BorderSide(
                    color: isLast ? Colors.grey[300]! : Colors.transparent,
                    width: 1.5,
                  )
                : BorderSide.none),
        borderRadius: BorderRadius.only(
          bottomLeft: isLast ? Radius.circular(8) : Radius.zero,
          bottomRight: isLast ? Radius.circular(8) : Radius.zero,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {}, // Add functionality for link navigation
                  child: Text(
                    tender.title,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // RichText(
                //   text: TextSpan(
                //     style: DefaultTextStyle.of(context).style,
                //     children: [
                //       TextSpan(
                //         text: "Contract Value: ",
                //         style: TextStyle(fontWeight: FontWeight.bold),
                //       ),
                //       TextSpan(
                //         // text: " (USD) ${tender.contractValue}",
                //         text: " (USD) 12",
                //         style: TextStyle(
                //             color: Colors.blue, fontWeight: FontWeight.bold),
                //       ),
                //     ],
                //   ),
                // ),
                _buildDetailRow(
                    Icons.calendar_month,
                    "Posted Date",
                    tender.closingDate != null
                        ? formatDate(tender.closingDate!)
                        : "N/A",
                    color: Theme.of(context).primaryColor),

                _buildDetailRow(
                    Icons.calendar_month,
                    "Expiry Date",
                    tender.closingDate != null
                        ? formatDate(tender.closingDate!)
                        : "N/A",
                    color: Theme.of(context).secondaryHeaderColor),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailRow(
                        Icons.location_on, "Location", tender.location,
                        color: Theme.of(context).secondaryHeaderColor),
                    IconButton(
                        onPressed:
                            _shareContent, // Add functionality for sharing
                        icon: Icon(Icons.share_rounded, color: Colors.blue)),
                  ],
                ),
                SizedBox(height: 12),
                if (!isLast)
                  const Divider(
                    thickness: 2,
                    color: Color(0x993385BB),
                  ),
                // _buildDetailRow(Icons.assignment, "Tender Type", tender.tenderType),
              ],
            ),
          ),
          // GestureDetector(
          //   onTap: () {
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (_) => TenderDetailPage(tenderId: tender.id)));
          //   },
          //   child: Container(
          //     width: double.infinity,
          //     margin: const EdgeInsets.only(top: 8),
          //     padding: const EdgeInsets.all(8),
          //     decoration: BoxDecoration(
          //       color: Colors.blue,
          //       borderRadius: BorderRadius.only(
          //         bottomLeft: Radius.circular(8),
          //         bottomRight: Radius.circular(8),
          //       ),
          //     ),
          //     child: Center(
          //       child: const Text(
          //         "See Details",
          //         style: TextStyle(
          //             fontSize: 16,
          //             fontWeight: FontWeight.bold,
          //             color: Colors.white),
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {Color color = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label ",
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(width: 8),
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String formatDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    List<String> weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = months[dateTime.month - 1];
    String weekday = weekdays[dateTime.weekday - 1];
    return "$weekday, $day $month, ${dateTime.year}";
  }
}

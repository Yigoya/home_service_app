import 'package:flutter/material.dart';
import 'package:home_service_app/provider/booking_provider.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookingDetailsPage extends StatelessWidget {
  const BookingDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Booking Details'),
        ),
        body: Consumer<BookingProvider>(builder: (context, provider, child) {
          final bookingData = provider.bookingData;
          Logger().d(bookingData);
          if (bookingData.isEmpty || provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final serviceLocation = bookingData['serviceLocation'];
          final questions = bookingData['questions'];
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer and Technician Details
                _buildSectionTitle('Customer Information'),
                _buildInfoRow('Name', bookingData['customerName']),
                _buildInfoRow('Technician', bookingData['technicianName']),

                // Service Details
                SizedBox(height: 16.0.h),
                _buildSectionTitle('Service Information'),
                _buildInfoRow('Service Name', bookingData['serviceName']),
                _buildInfoRow('Description', bookingData['serviceDescription']),
                _buildInfoRow('Scheduled Date',
                    bookingData['scheduledDate'] ?? 'Not set'),
                _buildInfoRow('Status', bookingData['status']),
                _buildInfoRow('Total Cost',
                    bookingData['totalCost']?.toString() ?? 'N/A'),

                // Location Details
                SizedBox(height: 16.0.h),
                _buildSectionTitle('Service Location'),
                _buildInfoRow('Street', serviceLocation['street'] ?? 'Not set'),
                _buildInfoRow('City', serviceLocation['city'] ?? 'Not set'),
                _buildInfoRow(
                    'Subcity', serviceLocation['subcity'] ?? 'Not set'),
                _buildInfoRow('Wereda', serviceLocation['wereda'] ?? 'Not set'),
                _buildInfoRow('State', serviceLocation['state'] ?? 'Not set'),
                _buildInfoRow(
                    'Country', serviceLocation['country'] ?? 'Not set'),
                _buildInfoRow(
                    'Latitude',
                    serviceLocation['latitude'] != null
                        ? serviceLocation['latitude'].toString()
                        : 'Not set'),
                _buildInfoRow(
                    'Longitude',
                    serviceLocation['latitude'] != null
                        ? serviceLocation['longitude'].toString()
                        : 'Not set'),

                // Questions and Answers
                SizedBox(height: 16.0.h),
                _buildSectionTitle('Questions and Answers'),
                ...questions
                    .map<Widget>((question) => _buildQuestionCard(question))
                    .toList(),
              ],
            ),
          );
        }));
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    final answers = question['answers'] as List<dynamic>;
    final options = question['options'] as List<dynamic>;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0.h),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(12.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['text'],
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0.h),
            if (question['type'] == 'MULTIPLE_CHOICE')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Options:',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  ...options.map((option) {
                    return Text(
                      '- ${option['optionText']}',
                      style: TextStyle(fontSize: 14.sp),
                    );
                  }),
                ],
              ),
            SizedBox(height: 8.0.h),
            if (answers.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Answers:',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  ...answers.map((answer) {
                    return Text(
                      '- ${answer['response']} (by ${answer['customerName']})',
                      style: TextStyle(fontSize: 14.sp),
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

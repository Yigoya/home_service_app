import 'package:flutter/material.dart';
import 'package:home_service_app/provider/booking_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BookingDetailsPage extends StatelessWidget {
  const BookingDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: Colors.white,
      ),
      body: Consumer<BookingProvider>(builder: (context, provider, child) {
        final bookingData = provider.bookingData;
        if (bookingData.isEmpty || provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final serviceLocation = bookingData['serviceLocation'];
        final questions = bookingData['questions'];
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Information Section
              _buildSection(
                title: AppLocalizations.of(context)!.customerInformation,
                icon: Icons.person,
                children: [
                  _buildInfoRow('Name', bookingData['customerName']),
                  _buildInfoRow('Technician', bookingData['technicianName']),
                ],
              ),

              // Service Information Section
              _buildSection(
                title: 'Service Information',
                icon: Icons.info,
                children: [
                  _buildInfoRow('Service Name', bookingData['serviceName']),
                  _buildInfoRow(
                      'Description', bookingData['serviceDescription']),
                  _buildInfoRow(AppLocalizations.of(context)!.scheduledDate,
                      bookingData['scheduledDate'] ?? 'Not set'),
                  _buildInfoRow('Status', bookingData['status']),
                  _buildInfoRow('Total Cost',
                      bookingData['totalCost']?.toString() ?? 'N/A'),
                ],
              ),

              // Location Details Section
              _buildSection(
                title: 'Service Location',
                icon: Icons.location_on,
                children: [
                  _buildInfoRow(
                      'Street', serviceLocation['street'] ?? 'Not set'),
                  _buildInfoRow('City', serviceLocation['city'] ?? 'Not set'),
                  _buildInfoRow(
                      'Subcity', serviceLocation['subcity'] ?? 'Not set'),
                  _buildInfoRow(
                      'Wereda', serviceLocation['wereda'] ?? 'Not set'),
                  _buildInfoRow('State', serviceLocation['state'] ?? 'Not set'),
                  _buildInfoRow(
                      'Country', serviceLocation['country'] ?? 'Not set'),
                  _buildInfoRow('Latitude',
                      serviceLocation['latitude']?.toString() ?? 'Not set'),
                  _buildInfoRow('Longitude',
                      serviceLocation['longitude']?.toString() ?? 'Not set'),
                ],
              ),

              // Questions and Answers Section
              _buildSection(
                title: 'Questions and Answers',
                icon: Icons.question_answer,
                children: questions
                    .map<Widget>((question) => _buildQuestionCard(question))
                    .toList(),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSection(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 10.0,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.black87),
                const SizedBox(width: 8.0),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    final answers = question['answers'] as List<dynamic>;
    final options = question['options'] as List<dynamic>;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 10.0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['text'],
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 12.0),
            if (question['type'] == 'MULTIPLE_CHOICE')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Options:',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8.0),
                  ...options.map((option) {
                    return Text(
                      '- ${option['optionText']}',
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54),
                    );
                  }),
                ],
              ),
            const SizedBox(height: 12.0),
            if (answers.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Answers:',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8.0),
                  ...answers.map((answer) {
                    return Text(
                      '- ${answer['response']} (by ${answer['customerName']})',
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54),
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

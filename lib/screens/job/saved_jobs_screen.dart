import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/screens/job/core/constants/color.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  final List<Map<String, String>> savedJobs = [
    {
      'title': 'Senior Product Designer',
      'company': 'Acme Co.',
      'location': 'Remote',
    },
    {
      'title': 'UX/UI Designer',
      'company': 'Tech Innovators Inc.',
      'location': 'New York, NY',
    },
    {
      'title': 'Frontend Developer',
      'company': 'Digital Solutions LLC',
      'location': 'San Francisco, CA',
    },
  ];

  Widget _savedJobCard(Map<String, String> job) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: kCardColorLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kGrey300.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: kGrey200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.work_outline, color: kPrimaryColor, size: 28),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['title']!,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 2.h),
                Text(
                  job['company']!,
                  style: TextStyle(color: kGrey600, fontSize: 14),
                ),
                SizedBox(height: 2.h),
                Text(
                  job['location']!,
                  style: TextStyle(color: kGrey400, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.bookmark_border, color: kPrimaryColor, size: 26),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kCardColorLight,
        elevation: 0,
        title: Text('Saved Jobs',
            style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: kTextPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: ListView.builder(
          itemCount: savedJobs.length,
          itemBuilder: (context, idx) => _savedJobCard(savedJobs[idx]),
        ),
      ),
    );
  }
}

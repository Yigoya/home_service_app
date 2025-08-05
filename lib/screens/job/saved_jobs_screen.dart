import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/screens/job/auth/job_finder_login.dart';
import 'package:home_service_app/screens/job/core/constants/color.dart';
import 'package:home_service_app/provider/job_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:home_service_app/screens/job/job_details_screen.dart';
import 'package:home_service_app/screens/job/auth/return_destination.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch saved jobs when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      final user = userProvider.user;
      if (user != null) {
        jobProvider.fetchSavedJobs(user.id);
      }
    });
  }

  Widget _savedJobCard(
      job, BuildContext context, JobProvider jobProvider, int userId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsScreen(initialJob: job),
          ),
        );
      },
      child: Container(
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
                    job.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    job.companyName,
                    style: TextStyle(color: kGrey600, fontSize: 14),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    job.companyLocation ?? job.jobLocation,
                    style: TextStyle(color: kGrey400, fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.bookmark, color: kPrimaryColor, size: 26),
              tooltip: 'Unsave Job',
              onPressed: () async {
                await jobProvider.unsaveJob(userId, job.id);
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text('Job removed from saved'),
                //     backgroundColor: Colors.red,
                //   ),
                // );
              },
            ),
          ],
        ),
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
        automaticallyImplyLeading: false,
        title: Text('Saved Jobs',
            style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: kTextPrimary),
      ),
      body: Consumer2<JobProvider, UserProvider>(
        builder: (context, jobProvider, userProvider, _) {
          final user = userProvider.user;

          // Check if user is logged in
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 64,
                    color: kGrey400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Login to view saved jobs',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to access your saved job listings',
                    style: TextStyle(
                      fontSize: 16,
                      color: kGrey600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // User is not logged in, navigate to job finder login
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobFinderLoginPage(
                            returnDestination: ReturnDestination.savedJobs,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (jobProvider.isLoadingSavedJobs) {
            return const Center(child: CircularProgressIndicator());
          }
          if (jobProvider.savedJobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 64,
                    color: kGrey400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved jobs yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start saving jobs to see them here',
                    style: TextStyle(
                      fontSize: 16,
                      color: kGrey600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          // Always use jobProvider.savedJobs directly
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: ListView.builder(
              itemCount: jobProvider.savedJobs.length,
              itemBuilder: (context, idx) => _savedJobCard(
                jobProvider.savedJobs[idx],
                context,
                jobProvider,
                user?.id ?? 0,
              ),
            ),
          );
        },
      ),
    );
  }
}

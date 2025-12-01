import 'package:flutter/material.dart';
import 'package:home_service_app/screens/job/core/constants/color.dart';
import 'package:home_service_app/models/job_model.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:timeago/timeago.dart' as timeago;

class ApplyScreen extends StatefulWidget {
  final JobModel job;

  const ApplyScreen({
    super.key,
    required this.job,
  });

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final TextEditingController _coverLetterController = TextEditingController();
  final int _coverLetterMax = 2000;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found. Please login again.')),
        );
        return;
      }

      // Get resume URL from user's job seeker profile
      String? resumeUrl;
      if (userProvider.jobSeekerProfile != null) {
        resumeUrl = userProvider.jobSeekerProfile!['resumeUrl'];
      }

      if (resumeUrl == null || resumeUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please upload your resume in your profile first.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      Logger().d('Submitting application for job: ${widget.job.id}');
      Logger().d('User ID: ${user.id}');
      Logger().d('Resume URL: $resumeUrl');

      final response = await ApiService().submitJobApplication(
        jobId: widget.job.id,
        userId: user.id,
        coverLetter: _coverLetterController.text,
        resumeUrl: resumeUrl,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Go back to job details
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit application. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Logger().e('Error submitting application: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kCardColorLight,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.close, color: kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('Apply',
            style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Image.asset('assets/images/profile.png',
                            width: 40, height: 40, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.job.title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22)),
                        const SizedBox(height: 2),
                        Text(widget.job.companyName ?? 'Unknown Company',
                            style: TextStyle(color: kGrey600, fontSize: 16)),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 30),

                // Job Card
                const Text('Job Summary',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: kCardColorLight,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: kGrey300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.work_outline, size: 18, color: kGrey600),
                          const SizedBox(width: 8),
                          Text(widget.job.jobType,
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 18, color: kGrey600),
                          const SizedBox(width: 8),
                          Text(widget.job.jobLocation,
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.attach_money, size: 18, color: kGrey600),
                          const SizedBox(width: 8),
                          Text(widget.job.salaryRange,
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 18, color: kGrey600),
                          const SizedBox(width: 8),
                          Text(
                              'Posted ${timeago.format(DateTime.parse(widget.job.postedDate))}',
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Resume Status
                const Text('Your Resume',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: kCardColorLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kGrey300),
                  ),
                  child: Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      final resumeUrl =
                          userProvider.jobSeekerProfile?['resumeUrl'];
                      if (resumeUrl != null && resumeUrl.isNotEmpty) {
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.check_circle,
                                  color: Colors.green, size: 28),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Resume uploaded ✓',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)),
                                  SizedBox(height: 2),
                                  Text('Ready for application',
                                      style: TextStyle(
                                          color: kGrey600, fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.warning,
                                  color: Colors.orange, size: 28),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Resume not uploaded',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)),
                                  SizedBox(height: 2),
                                  Text('Please upload resume in your profile',
                                      style: TextStyle(
                                          color: kGrey600, fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 28),

                // Cover Letter
                const Text('Cover Letter (Required)',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: kCardColorLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kGrey300),
                  ),
                  child: Stack(
                    children: [
                      TextFormField(
                        controller: _coverLetterController,
                        maxLines: 8,
                        maxLength: _coverLetterMax,
                        decoration: const InputDecoration(
                          hintText:
                              'Explain why you\'re a great fit for this role...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please write a cover letter';
                          }
                          if (value.length < 50) {
                            return 'Cover letter should be at least 50 characters';
                          }
                          return null;
                        },
                      ),
                      Positioned(
                        right: 12,
                        bottom: 8,
                        child: Text(
                          '${_coverLetterController.text.length} / $_coverLetterMax',
                          style: TextStyle(color: kGrey600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('Submitting...'),
                            ],
                          )
                        : Text('Submit Application'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/models/job_model.dart';
import 'package:home_service_app/provider/job_provider.dart';
import 'package:home_service_app/screens/job/apply_screen.dart';
import 'package:home_service_app/screens/job/core/constants/color.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:home_service_app/provider/auth_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/job/auth/job_finder_login.dart';
import 'package:home_service_app/screens/job/auth/return_destination.dart';
import 'package:timeago/timeago.dart' as timeago;

class JobDetailsScreen extends StatefulWidget {
  final JobModel initialJob;

  const JobDetailsScreen({
    Key? key,
    required this.initialJob,
  }) : super(key: key);

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  JobModel? _detailedJob;
  bool _isLoadingDetails = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetailedJob();
  }

  Future<void> _loadDetailedJob() async {
    setState(() {
      _isLoadingDetails = true;
      _errorMessage = null;
    });

    try {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      final detailedJob =
          await jobProvider.fetchJobDetails(widget.initialJob.id);

      if (mounted) {
        setState(() {
          _detailedJob = detailedJob;
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load detailed information';
          _isLoadingDetails = false;
        });
      }
    }
  }

  JobModel get currentJob => _detailedJob ?? widget.initialJob;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Job Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: kPrimaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: kPrimaryColor),
            onPressed: () {
              final shareText =
                  '${currentJob.title} at ${currentJob.companyName}\nLocation: ${currentJob.companyLocation ?? currentJob.jobLocation}\n${currentJob.description.substring(0, currentJob.description.length > 100 ? 100 : currentJob.description.length) + (currentJob.description.length > 100 ? '...' : '')}';
              Share.share(shareText);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(),
            Divider(
              color: Colors.grey.withOpacity(0.4),
              thickness: 1,
            ),

            // Error message if failed to load details
            if (_errorMessage != null) _buildErrorMessage(),

            // Content Sections
            _buildAboutSection(),
            if (_isLoadingDetails) ...[
              _buildShimmerQualificationsSection(),
              _buildShimmerResponsibilitiesSection(),
              _buildShimmerBenefitsSection(),
            ] else ...[
              if (currentJob.responsibilities.isNotEmpty)
                _buildResponsibilitiesSection(),
              if (currentJob.qualifications.isNotEmpty)
                _buildQualificationsSection(),
              if (currentJob.benefits.isNotEmpty) _buildBenefitsSection(),
            ],

            // Bottom spacing for button
            SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildApplyButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w).copyWith(bottom: 5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: currentJob.companyLogo != null
                    ? Image.network(currentJob.companyLogo!, fit: BoxFit.cover)
                    : Center(
                        child: Text(
                          currentJob.companyName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentJob.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.apartment, size: 17, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          currentJob.companyName,
                          style: TextStyle(color: Colors.grey, fontSize: 17),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 17, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          currentJob.companyLocation ?? currentJob.jobLocation,
                          style: TextStyle(color: Colors.grey, fontSize: 17),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 17, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          timeago.format(
                            DateTime.parse(currentJob.postedDate),
                          ),
                          style: TextStyle(color: Colors.grey, fontSize: 17),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 17, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          currentJob.salaryRange,
                          style: TextStyle(color: Colors.grey, fontSize: 17),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.work, size: 17, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          currentJob.jobType,
                          style: TextStyle(color: Colors.grey, fontSize: 17),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.trending_up, size: 17, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          currentJob.level,
                          style: TextStyle(color: Colors.grey, fontSize: 17),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // SizedBox(height: 16.h),
          // Wrap(
          //   spacing: 8.w,
          //   runSpacing: 8.h,
          //   children: [
          //     _pillChip(currentJob.jobType, kPrimaryColor),
          //     if (currentJob.level.isNotEmpty)
          //       _pillChip(currentJob.level, Colors.blue),
          //     _pillChip(currentJob.jobLocation, Colors.blue),
          //     _pillChip(currentJob.salaryRange, Colors.black),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.orange, size: 16),
          SizedBox(width: 8.w),
          Text(
            _errorMessage!,
            style: TextStyle(color: Colors.orange, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Text(
              'Introduction',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: kPrimaryColor,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.w),
            child: Text(
              currentJob.description,
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerQualificationsSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 12.h),
                _buildShimmerBulletList(),
              ],
            ),
          ),
          SizedBox(height: 18.h),
        ],
      ),
    );
  }

  Widget _buildShimmerResponsibilitiesSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 12.h),
                _buildShimmerBulletList(),
              ],
            ),
          ),
          SizedBox(height: 18.h),
        ],
      ),
    );
  }

  Widget _buildShimmerBenefitsSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 12.h),
                _buildShimmerBulletList(),
              ],
            ),
          ),
          SizedBox(height: 18.h),
        ],
      ),
    );
  }

  Widget _buildShimmerBulletList() {
    return Column(
      children: List.generate(
          3,
          (index) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 4,
                      width: 4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
    );
  }

  Widget _buildQualificationsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Text(
              'Requirements',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: kPrimaryColor,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.w),
            child: _bulletList(currentJob.qualifications),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsibilitiesSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Text(
              'Duties & Responsibilities',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: kPrimaryColor,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.w),
            child: _bulletList(currentJob.responsibilities),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Text(
              'Benefits',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: kPrimaryColor,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.w),
            child: _bulletList(currentJob.benefits),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SaveButton(
        text: 'Apply for this Job',
        onPressed: () => _handleApplyToJob(),
        height: 50.h,
      ),
    );
  }

  Future<void> _handleApplyToJob() async {
    // Check if user is logged in using UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null) {
      // User is not logged in, navigate to job finder login with return destination
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobFinderLoginPage(
            returnDestination: ReturnDestination.applyJob,
            returnData: {'job': currentJob},
          ),
        ),
      );
    } else {
      // User is logged in, proceed to apply screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ApplyScreen(job: currentJob),
        ),
      );
    }
  }

  Widget _pillChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _bulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(fontSize: 18, height: 1.3)),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(fontSize: 15, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

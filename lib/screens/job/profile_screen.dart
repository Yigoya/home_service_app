import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/screens/job/edit_profile_screen.dart';
import 'package:home_service_app/screens/job/core/constants/color.dart';
import 'package:provider/provider.dart';
import 'package:home_service_app/provider/auth_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/job/auth/job_finder_login.dart';
import 'package:home_service_app/screens/job/auth/job_finder_signup.dart';
import 'package:home_service_app/utils/functions.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:home_service_app/screens/job/auth/return_destination.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _jobSeekerData;
  final List<String> skills = [
    'Product Design',
    'UI/UX',
    'User Research',
    'Wireframing',
    'Prototyping'
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh login status when dependencies change (e.g., after login/logout)
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = await authProvider.storage.read(key: "jwt_token");
    final jobSeekerData = await authProvider.storage.read(key: "jobSeeker");

    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
      if (jobSeekerData != null) {
        try {
          _jobSeekerData = Map<String, dynamic>.from(jsonDecode(jobSeekerData));
        } catch (e) {
          Logger().e('Error parsing job seeker data: $e');
        }
      }

      // Also check if we have user data from UserProvider
      if (_isLoggedIn && userProvider.user != null) {
        Logger()
            .d('User data from UserProvider: ${userProvider.user?.toJson()}');
      }
    });

    // If user is logged in and is a job seeker, fetch profile from UserProvider
    if (_isLoggedIn && userProvider.isJobSeeker) {
      Logger().d('User is logged in and is a job seeker, fetching profile...');
      await userProvider.fetchJobSeekerProfile();
    } else {
      Logger().d(
          'User is logged in: $_isLoggedIn, isJobSeeker: ${userProvider.isJobSeeker}');
    }
  }

  Future<void> _logout() async {
    try {
      final authProvider =
          Provider.of<AuthenticationProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Clear all stored data
      await authProvider.storage.deleteAll();
      await userProvider.clearUser();

      setState(() {
        _isLoggedIn = false;
        _jobSeekerData = null;
      });

      showTopMessage(context, 'Logged out successfully', isSuccess: true);

      // Navigate back to job search screen
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      Logger().e('Error during logout: $e');
      showTopMessage(context, 'Error during logout', isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kCardColorLight,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Profile',
            style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: kTextPrimary),
        actions: _isLoggedIn
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: Icon(Icons.edit, color: kPrimaryColor),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _isLoggedIn
              ? () async {
                  final userProvider =
                      Provider.of<UserProvider>(context, listen: false);
                  Logger().d(
                      'Pull to refresh triggered. isJobSeeker: ${userProvider.isJobSeeker}');
                  if (userProvider.isJobSeeker) {
                    await userProvider.fetchJobSeekerProfile();
                  } else {
                    // Try to fetch anyway for debugging
                    Logger().d(
                        'Attempting to fetch profile anyway for user: ${userProvider.user?.toJson()}');
                    await userProvider.fetchJobSeekerProfile();
                  }
                }
              : () async {},
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
              child: _isLoggedIn
                  ? _buildLoggedInProfile()
                  : _buildNotLoggedInProfile(),
            ),
          ),
        ),
      ),
    );
  }

  String _getFullProfileImageUrl(String profileImage) {
    // If it's already a full URL, return as is
    if (profileImage.startsWith('http://') ||
        profileImage.startsWith('https://')) {
      return profileImage;
    }
    // Otherwise, construct the full URL
    return 'https://hulumoya.zapto.org/uploads/$profileImage';
  }

  Future<void> _previewResume(String? resumeUrl) async {
    if (resumeUrl == null || resumeUrl.isEmpty) {
      showTopMessage(context, 'No resume available to preview',
          isSuccess: false);
      return;
    }

    try {
      final Uri url = Uri.parse(resumeUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        showTopMessage(context, 'Could not open resume', isSuccess: false);
      }
    } catch (e) {
      Logger().e('Error opening resume: $e');
      showTopMessage(context, 'Error opening resume', isSuccess: false);
    }
  }

  Widget _buildLoggedInProfile() {
    final userInfo = getUserInfo();
    final userName = userInfo?['name'] ?? 'User';
    final userTitle = userInfo?['headline'] ?? 'Job Seeker';
    final userId = getUserId();
    final userSummary = userInfo?['summary'];
    final userSkills = userInfo?['skills'] as List<dynamic>?;
    final resumeUrl = userInfo?['resumeUrl'];
    final profileImage = userInfo?['profileImage'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
          decoration: BoxDecoration(
            color: kCardColorLight,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kGrey300.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 44.r,
                backgroundImage: profileImage != null
                    ? NetworkImage(_getFullProfileImageUrl(profileImage!))
                        as ImageProvider
                    : const AssetImage('assets/images/profile.png'),
              ),
              const SizedBox(height: 12),
              Text(
                userName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                userTitle,
                style: TextStyle(color: kGrey600, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          decoration: BoxDecoration(
            color: kCardColorLight,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kGrey300.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: // Resume
              Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.file_present_rounded,
                    color: kPrimaryColor, size: 28),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resume',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    resumeUrl != null && resumeUrl.isNotEmpty
                        ? 'Resume uploaded'
                        : 'No resume uploaded',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              Spacer(),
              Row(
                children: [
                  if (resumeUrl != null && resumeUrl.isNotEmpty)
                    OutlinedButton(
                      onPressed: () => _previewResume(resumeUrl),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: kPrimaryColor.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(24))),
                        padding:
                            EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                      ),
                      child: Text('Preview',
                          style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Summary section (if available)
        if (userSummary != null && userSummary.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            decoration: BoxDecoration(
              color: kCardColorLight,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kGrey300.withOpacity(0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userSummary,
                  style: TextStyle(fontSize: 14, color: kGrey600),
                ),
              ],
            ),
          ),
        if (userSummary != null && userSummary.isNotEmpty)
          const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          decoration: BoxDecoration(
            color: kCardColorLight,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kGrey300.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Skills',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (userSkills ?? skills)
                      .map((skill) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              skill.toString(),
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Job Preferences
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          decoration: BoxDecoration(
            color: kCardColorLight,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kGrey300.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Job Preferences',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 18, color: kPrimaryColor),
                  const SizedBox(width: 6),
                  const Text('Remote, San Francisco, CA',
                      style: TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.work_outline, size: 18, color: kPrimaryColor),
                  const SizedBox(width: 6),
                  const Text('Full-time', style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Settings List
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: kCardColorLight,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kGrey300.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                minTileHeight: 30,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.bookmark_border,
                      color: kPrimaryColor, size: 20),
                ),
                title: const Text('My Saved Jobs'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                minTileHeight: 30,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.assignment_outlined,
                      color: kPrimaryColor, size: 20),
                ),
                title: const Text('My Applications'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                minTileHeight: 30,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.language, color: kPrimaryColor, size: 20),
                ),
                title: const Text('Language & Preferences'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                minTileHeight: 30,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: kErrorColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.logout, color: kErrorColor, size: 20),
                ),
                title: Text('Logout', style: TextStyle(color: kErrorColor)),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotLoggedInProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile Card for not logged in users
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
          decoration: BoxDecoration(
            color: kCardColorLight,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kGrey300.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 44.r,
                backgroundColor: kGrey300,
                child: Icon(
                  Icons.person_outline,
                  size: 44.r,
                  color: kGrey600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Welcome to Job Finder',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                'Create your profile to start applying for jobs',
                style: TextStyle(color: kGrey600, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobFinderLoginPage(
                              returnDestination: ReturnDestination.profile,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JobFinderSignupPage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: kPrimaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Features preview
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          decoration: BoxDecoration(
            color: kCardColorLight,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kGrey300.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'App Settings & Support:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(Icons.feedback_outlined, 'Send Feedback'),
              _buildFeatureItem(Icons.share_outlined, 'Share App'),
              _buildFeatureItem(Icons.star_outline, 'Rate App'),
              _buildFeatureItem(Icons.privacy_tip_outlined, 'Privacy Policy'),
              _buildFeatureItem(
                  Icons.description_outlined, 'Terms and Conditions'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: kPrimaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: kGrey600),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get user information
  Map<String, dynamic>? getUserInfo() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // First try to get data from UserProvider (if user is a job seeker)
    if (userProvider.isJobSeeker && userProvider.jobSeekerProfile != null) {
      final profile = userProvider.jobSeekerProfile!;
      return {
        'id': profile['userId'],
        'name': profile['name'],
        'email': profile['email'],
        'phoneNumber': profile['phoneNumber'],
        'headline': profile['headline'],
        'summary': profile['summary'],
        'resumeUrl': profile['resumeUrl'],
        'skills': profile['skills'],
        'role': profile['role'],
        'profileImage': profile['profileImage'],
        'status': profile['status'],
        'preferredLanguage': profile['preferredLanguage'],
      };
    }

    // Fallback to stored job seeker data
    if (_jobSeekerData != null) {
      return {
        'id': _jobSeekerData?['userId'],
        'name': _jobSeekerData?['name'],
        'email': _jobSeekerData?['email'],
        'phoneNumber': _jobSeekerData?['phoneNumber'],
        'headline': _jobSeekerData?['headline'],
        'summary': _jobSeekerData?['summary'],
        'resumeUrl': _jobSeekerData?['resumeUrl'],
        'skills': _jobSeekerData?['skills'],
        'role': _jobSeekerData?['role'],
        'profileImage': _jobSeekerData?['profileImage'],
        'status': _jobSeekerData?['status'],
        'preferredLanguage': _jobSeekerData?['preferredLanguage'],
      };
    }

    // Final fallback to UserProvider user data
    if (userProvider.user != null) {
      return {
        'id': userProvider.user?.id,
        'name': userProvider.user?.name,
        'email': userProvider.user?.email,
        'phoneNumber': userProvider.user?.phoneNumber,
        'role': userProvider.user?.role,
      };
    }

    return null;
  }

  // Helper method to get user ID specifically
  String? getUserId() {
    final userInfo = getUserInfo();
    return userInfo?['id']?.toString();
  }
}

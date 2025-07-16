import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/screens/job/edit_profile_screen.dart';
import 'package:home_service_app/screens/job/core/constants/color.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<String> skills = [
    'Product Design',
    'UI/UX',
    'User Research',
    'Wireframing',
    'Prototyping'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kCardColorLight,
        elevation: 0,
        title: Text('Profile',
            style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: kTextPrimary),
        actions: [
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
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Card
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
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
                        backgroundImage:
                            const AssetImage('assets/images/profile-2.png'),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Yihun Alemayehu',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Software Engineer',
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
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
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resume',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Yihun_Alemayehu_re....pdf',
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),
                      Spacer(),
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              kPrimaryColor.withOpacity(0.08)),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Update',
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
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
                          children: skills
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
                                      skill,
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
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
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
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
                          Icon(Icons.work_outline,
                              size: 18, color: kPrimaryColor),
                          const SizedBox(width: 6),
                          const Text('Full-time',
                              style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Settings List
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
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
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
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
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.language,
                              color: kPrimaryColor, size: 20),
                        ),
                        title: const Text('Language & Preferences'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      ListTile(
                        minTileHeight: 30,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: kErrorColor.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(Icons.logout, color: kErrorColor, size: 20),
                        ),
                        title: Text('Logout',
                            style: TextStyle(color: kErrorColor)),
                        onTap: () {},
                      ),
                    ],
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

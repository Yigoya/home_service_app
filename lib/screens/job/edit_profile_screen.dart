import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/screens/job/core/constants/color.dart';
import 'package:provider/provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/utils/functions.dart';
import 'package:logger/logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _headlineController = TextEditingController();
  final _summaryController = TextEditingController();
  List<String> _skills = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _selectedResumePath;
  String? _currentResumeUrl;
  String? _selectedProfileImagePath;
  String? _currentProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.isJobSeeker && userProvider.jobSeekerProfile != null) {
      final profile = userProvider.jobSeekerProfile!;

      setState(() {
        _nameController.text = profile['name'] ?? '';
        _phoneController.text = profile['phoneNumber'] ?? '';
        _headlineController.text = profile['headline'] ?? '';
        _summaryController.text = profile['summary'] ?? '';
        _currentResumeUrl = profile['resumeUrl'];
        _currentProfileImageUrl = profile['profileImage'];
        _skills = profile['skills'] != null
            ? (profile['skills'] is String
                ? profile['skills']
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList()
                : List<String>.from(profile['skills']))
            : [];
        _isInitialized = true;
      });
    } else {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _headlineController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _addSkill() async {
    final skill = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Skill'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Skill name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('Add')),
          ],
        );
      },
    );
    if (skill != null && skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() => _skills.add(skill));
    }
  }

  Future<void> _pickResume() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedResumePath = result.files.first.path;
        });
      }
    } catch (e) {
      Logger().e('Error picking resume file: $e');
      showTopMessage(context, 'Error selecting resume file', isSuccess: false);
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedProfileImagePath = result.files.first.path;
        });
      }
    } catch (e) {
      Logger().e('Error picking profile image: $e');
      showTopMessage(context, 'Error selecting profile image',
          isSuccess: false);
    }
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

  Future<void> _saveProfile() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (!userProvider.isJobSeeker) {
        showTopMessage(context, 'User is not a job seeker', isSuccess: false);
        return;
      }

      // Get current profile data as base
      final currentProfile = userProvider.jobSeekerProfile!;
      final profileData = <String, dynamic>{};

      // Send full data - use new values if changed, existing values if not changed
      final name = _nameController.text.trim();
      profileData['name'] =
          name.isNotEmpty ? name : (currentProfile['name'] ?? '');

      final phoneNumber = _phoneController.text.trim();
      profileData['phoneNumber'] = phoneNumber.isNotEmpty
          ? phoneNumber
          : (currentProfile['phoneNumber'] ?? '');

      final headline = _headlineController.text.trim();
      profileData['headline'] =
          headline.isNotEmpty ? headline : (currentProfile['headline'] ?? '');

      final summary = _summaryController.text.trim();
      profileData['summary'] =
          summary.isNotEmpty ? summary : (currentProfile['summary'] ?? '');

      final skills = _skills.join(', ');
      profileData['skills'] =
          skills.isNotEmpty ? skills : (currentProfile['skills'] ?? '');

      // Handle resume - use new URL if uploaded, existing URL if not
      if (_selectedResumePath != null) {
        final apiService = ApiService();
        final resumeUrl = await apiService.uploadJobSeekerResume(
          userId: userProvider.user!.id,
          filePath: _selectedResumePath!,
        );
        if (resumeUrl == null) {
          showTopMessage(context, 'Failed to upload resume', isSuccess: false);
          return;
        }
        profileData['resumeUrl'] = resumeUrl;
      } else {
        profileData['resumeUrl'] = currentProfile['resumeUrl'];
      }

      // Handle profile image - upload endpoint automatically updates the profile
      if (_selectedProfileImagePath != null) {
        final apiService = ApiService();
        final profileImageUrl = await apiService.uploadProfileImage(
          userId: userProvider.user!.id,
          filePath: _selectedProfileImagePath!,
        );
        if (profileImageUrl == null) {
          showTopMessage(context, 'Failed to upload profile image',
              isSuccess: false);
          return;
        }
        // Don't include profileImage in profileData since upload endpoint already updated it
      } else {
        profileData['profileImage'] = currentProfile['profileImage'];
      }

      await userProvider.updateJobSeekerProfile(profileData);

      showTopMessage(context, 'Profile updated successfully', isSuccess: true);
      Navigator.pop(context);
    } catch (e) {
      Logger().e('Error updating profile: $e');
      showTopMessage(context, 'Failed to update profile', isSuccess: false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: kBackgroundLight,
        appBar: AppBar(
          backgroundColor: kCardColorLight,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: kTextPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text('Edit Profile',
              style:
                  TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold)),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kCardColorLight,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('Edit Profile',
            style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Avatar with edit icon
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: kPrimaryColor.withOpacity(0.1),
                    backgroundImage: _selectedProfileImagePath != null
                        ? FileImage(File(_selectedProfileImagePath!))
                        : (_currentProfileImageUrl != null
                            ? NetworkImage(_getFullProfileImageUrl(
                                _currentProfileImageUrl!)) as ImageProvider
                            : const AssetImage('assets/images/profile-2.png')),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Material(
                      color: kPrimaryColor,
                      shape: const CircleBorder(),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _pickProfileImage,
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child:
                              Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Form fields
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Full Name',
                    style: TextStyle(
                        color: kGrey700, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Phone Number',
                    style: TextStyle(
                        color: kGrey700, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneController,
                decoration: _inputDecoration(hint: 'e.g. +1123 456 7890'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Professional Title (Headline)',
                    style: TextStyle(
                        color: kGrey700, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _headlineController,
                decoration: _inputDecoration(hint: 'e.g. Software Engineer'),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Summary/Bio',
                    style: TextStyle(
                        color: kGrey700, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _summaryController,
                decoration: _inputDecoration(hint: 'Tell us about yourself...'),
                maxLines: 4,
              ),
              const SizedBox(height: 22),
              // Skills
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Skills',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  GestureDetector(
                    onTap: _addSkill,
                    child: Text('Add Skill',
                        style: TextStyle(
                            color: kPrimaryColor, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skills
                      .map((skill) => Chip(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            surfaceTintColor: kPrimaryColor,
                            side: BorderSide(color: Colors.transparent),
                            label: Text(skill,
                                style: TextStyle(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.w500)),
                            backgroundColor: kPrimaryColor.withOpacity(0.1),
                            deleteIcon: Icon(Icons.close,
                                size: 18, color: kPrimaryColor),
                            onDeleted: () =>
                                setState(() => _skills.remove(skill)),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 32),
              // Resume
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Resume',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kGrey900)),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                        .copyWith(bottom: 5.h),
                decoration: BoxDecoration(
                  color: kCardColorLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kGrey300),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.insert_drive_file,
                              color: kPrimaryColor, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedResumePath != null
                                    ? _selectedResumePath!.split('/').last
                                    : (_currentResumeUrl != null
                                        ? 'Resume.pdf'
                                        : 'No resume uploaded'),
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _selectedResumePath != null
                                    ? 'New file selected'
                                    : (_currentResumeUrl != null
                                        ? 'Resume available'
                                        : 'Upload your resume'),
                                style: TextStyle(color: kGrey600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: _pickResume,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: kPrimaryColor.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(24))),
                            padding: EdgeInsets.symmetric(
                                horizontal: 18, vertical: 0),
                          ),
                          child: Text('Upload New',
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    if (_currentResumeUrl != null &&
                        _currentResumeUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: OutlinedButton(
                          onPressed: () => _previewResume(_currentResumeUrl),
                          style: OutlinedButton.styleFrom(
                            fixedSize: Size(
                                MediaQuery.of(context).size.width * .84, 40.h),
                            side: BorderSide(
                                color: kPrimaryColor.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(18.r))),
                            padding: EdgeInsets.symmetric(
                                horizontal: 18, vertical: 0),
                          ),
                          child: Text('Preview',
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Save Changes button
              SaveButton(
                onPressed: _isLoading ? null : _saveProfile,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({String? hint}) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: kCardColorLight,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: kGrey300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: kGrey300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: kPrimaryColor, width: 1.5),
    ),
  );
}

class SaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const SaveButton({super.key, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

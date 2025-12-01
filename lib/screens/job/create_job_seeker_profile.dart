import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:logger/logger.dart';

class CreateJobSeekerProfileScreen extends StatefulWidget {
  final int userId;
  final VoidCallback? onProfileCreated;
  const CreateJobSeekerProfileScreen(
      {required this.userId, this.onProfileCreated, Key? key})
      : super(key: key);

  @override
  State<CreateJobSeekerProfileScreen> createState() =>
      _CreateJobSeekerProfileScreenState();
}

class _CreateJobSeekerProfileScreenState
    extends State<CreateJobSeekerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _skillsController = TextEditingController();
  File? _resumeFile;
  bool _isLoading = false;

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _resumeFile = File(result.files.single.path!);
      });
    }
  }

  // https://hulumoya.zapto.org/profiles/seeker/{Id}/resume

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final skills = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      Logger().d('Creating job seeker profile first...');
      final response = await ApiService().createJobSeekerProfile(
        userId: widget.userId,
        headline: _titleController.text,
        summary: _summaryController.text,
        skills: _skillsController.text,
        resumeUrl: null, // Don't include resume URL initially
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Logger().d(
            'Profile created successfully, now uploading resume if selected...');

        // Now upload resume if file was selected
        if (_resumeFile != null) {
          Logger().d('Starting resume upload...');
          final resumeUrl = await ApiService().uploadJobSeekerResume(
            userId: widget.userId,
            filePath: _resumeFile!.path,
          );

          if (resumeUrl == null) {
            Logger().w(
                'Resume upload failed, but profile was created successfully');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Profile created successfully, but resume upload failed. You can upload it later.'),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            Logger().d('Resume uploaded successfully: $resumeUrl');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profile and resume uploaded successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        setState(() => _isLoading = false);

        if (widget.onProfileCreated != null) {
          widget.onProfileCreated!();
        } else {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        Logger()
            .e('Profile creation failed with status: ${response.statusCode}');
        Logger().e('Response data: ${response.data}');
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Logger().e('Error in _submitProfile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Create Job Seeker Profile'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF222B45)),
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold, color: const Color(0xFF222B45)),
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18.0, vertical: 24.0),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: const Icon(Icons.person_outline,
                                      size: 48, color: Color(0xFF3366FF)),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Let’s build your profile',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Stand out to employers by completing your job seeker profile.',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text('Title / Headline',
                              style: theme.textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: 'e.g. Senior Mobile Developer',
                              prefixIcon: const Icon(Icons.title_outlined),
                              filled: true,
                              fillColor: const Color(0xFFF6F7FB),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Title required'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          Text('Summary / Bio',
                              style: theme.textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _summaryController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText:
                                  'Tell us about yourself, your experience, and what you’re looking for... ',
                              prefixIcon: const Icon(Icons.short_text_rounded),
                              filled: true,
                              fillColor: const Color(0xFFF6F7FB),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Summary required'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          Text('Skills',
                              style: theme.textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _skillsController,
                            decoration: InputDecoration(
                              hintText:
                                  'e.g. Flutter, Dart, Firebase, REST API',
                              prefixIcon: const Icon(Icons.code),
                              filled: true,
                              fillColor: const Color(0xFFF6F7FB),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Skills required'
                                : null,
                            onChanged: (_) => setState(() {}),
                          ),
                          if (_skillsController.text.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: _skillsController.text
                                  .split(',')
                                  .map((s) => s.trim())
                                  .where((s) => s.isNotEmpty)
                                  .map((skill) => Chip(
                                        label: Text(skill),
                                        backgroundColor:
                                            const Color(0xFFEDF1FA),
                                        labelStyle: const TextStyle(
                                            color: Color(0xFF3366FF)),
                                      ))
                                  .toList(),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Text('Resume',
                              style: theme.textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickResume,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F7FB),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFE4E9F2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.upload_file,
                                      color: Color(0xFF3366FF)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _resumeFile != null
                                          ? _resumeFile!.path.split('/').last
                                          : 'Upload your resume (PDF, DOC, DOCX)',
                                      style: TextStyle(
                                        color: _resumeFile != null
                                            ? const Color(0xFF3366FF)
                                            : Colors.grey[600],
                                        fontWeight: _resumeFile != null
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (_resumeFile != null)
                                    const Icon(Icons.check_circle,
                                        color: Colors.green, size: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3366FF),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('Create Profile',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.08),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

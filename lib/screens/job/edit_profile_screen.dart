import 'package:flutter/material.dart';
import 'package:home_service_app/screens/job/core/constants/color.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: 'Yihun Alemayehu');
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _titleController = TextEditingController(text: 'Software Engineer');
  List<String> _skills = ['Flutter', 'Dart', 'Mobile app'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _titleController.dispose();
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

  @override
  Widget build(BuildContext context) {
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
                    backgroundImage:
                        const AssetImage('assets/images/profile-2.png'),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Material(
                      color: kPrimaryColor,
                      shape: const CircleBorder(),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {},
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
                child: Text('Location',
                    style: TextStyle(
                        color: kGrey700, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _locationController,
                decoration: _inputDecoration(hint: 'e.g. San Francisco, USA'),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Professional Title',
                    style: TextStyle(
                        color: kGrey700, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                decoration: _inputDecoration(),
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
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: kCardColorLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kGrey300),
                ),
                child: Row(
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Resume.pdf',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16)),
                          SizedBox(height: 2),
                          Text('Updated 2 days ago',
                              style: TextStyle(color: kGrey600, fontSize: 13)),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: kPrimaryColor.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(24))),
                        padding:
                            EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                      ),
                      child: Text('Upload New',
                          style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Save Changes button
              SaveButton(
                onPressed: () {},
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

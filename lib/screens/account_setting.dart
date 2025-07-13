import 'package:flutter/material.dart';
import 'package:home_service_app/l10n/app_localizations.dart';
import 'package:home_service_app/provider/profile_page_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:provider/provider.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  // Toast notification
  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }

  // Build an editable field with save functionality
  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required String field,
    required void Function() endpoint,
    String hintText = '',
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                    inputType == TextInputType.emailAddress
                        ? Icons.email
                        : inputType == TextInputType.phone
                            ? Icons.phone
                            : Icons.edit,
                    color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hintText,
                  border: InputBorder.none,
                ),
                keyboardType: inputType,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    if (controller.text.trim().isEmpty) {
                      _showToast('$label cannot be empty');
                      return;
                    }
                    endpoint();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Account Settings',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Edit Your Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Editable Name Field
                  _buildEditableField(
                    label: 'Full Name',
                    controller: _nameController,
                    field: 'name',
                    endpoint: () =>
                        Provider.of<ProfilePageProvider>(context, listen: false)
                            .updateProfile(
                                {'name': _nameController.text.trim()}, context),
                    hintText: 'Enter your full name',
                  ),
                  // Editable Email Field
                  _buildEditableField(
                    label: 'Email',
                    controller: _emailController,
                    field: 'email',
                    endpoint: () =>
                        Provider.of<UserProvider>(context, listen: false)
                            .changeEmail(_emailController.text.trim(), context),
                    hintText: 'Enter your email',
                    inputType: TextInputType.emailAddress,
                  ),
                  // Editable Phone Field
                  _buildEditableField(
                    label: 'Phone',
                    controller: _phoneController,
                    field: 'phone',
                    endpoint: () =>
                        Provider.of<UserProvider>(context, listen: false)
                            .changePhoneNumber(
                                _phoneController.text.trim(), context),
                    hintText: AppLocalizations.of(context)!
                        .enterYourPhoneNumberPrompt,
                    inputType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     // Add functionality to save all changes at once
                  //     if (_nameController.text.trim().isEmpty ||
                  //         _emailController.text.trim().isEmpty ||
                  //         _phoneController.text.trim().isEmpty) {
                  //       _showToast(AppLocalizations.of(context)!.allFieldsMustBeFilled);
                  //       return;
                  //     }
                  //     setState(() {
                  //       _isLoading = true;
                  //     });
                  //     // Simulate a network request
                  //     Future.delayed(const Duration(seconds: 2), () {
                  //       setState(() {
                  //         _isLoading = false;
                  //       });
                  //       _showToast(AppLocalizations.of(context)!.profileUpdatedSuccessfully);
                  //     });
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.blueAccent,
                  //     padding: const EdgeInsets.symmetric(
                  //         horizontal: 32, vertical: 12),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //   ),
                  //   child: const Text(
                  //     AppLocalizations.of(context)!.saveAllChanges,
                  //     style: TextStyle(
                  //       color: Colors.white,
                  //       fontSize: 16,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
    );
  }
}

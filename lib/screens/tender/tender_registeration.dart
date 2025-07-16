import 'package:flutter/material.dart';
import 'package:home_service_app/models/tender_user.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_field_validator/form_field_validator.dart'
    as ffv; // Add prefix;

class TenderRegisteration extends StatelessWidget {
  const TenderRegisteration({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Register for Tender',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const RegistrationContent(),
      ),
    );
  }
}

class RegistrationContent extends StatefulWidget {
  const RegistrationContent({super.key});

  @override
  State<RegistrationContent> createState() => _RegistrationContentState();
}

class _RegistrationContentState extends State<RegistrationContent> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final services =
        Provider.of<HomeServiceProvider>(context).fiterableByCatagory;
    final serviceNames = services.map((service) => service.name).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 16,
              ),
              const Text(
                'Register for Tender',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fill in the details below to register for tender access.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // // First Name (Required)
              // _buildTextField(
              //   name: 'firstName',
              //   label: 'First Name',
              //   validator: ffv.RequiredValidator(
              //       errorText: 'First name is required'), // Use prefix
              //   isRequired: true,
              // ),
              // const SizedBox(height: 16),

              // // Last Name (Required)
              // _buildTextField(
              //   name: 'lastName',
              //   label: 'Last Name',
              //   validator: ffv.RequiredValidator(
              //       errorText: 'Last name is required'), // Use prefix
              //   isRequired: true,
              // ),
              // const SizedBox(height: 16),

              // Email/Mobile (Required)
              _buildTextField(
                name: 'emailOrMobile',
                label: 'Your Mobile/Email Address',
                validator: ffv.MultiValidator([
                  ffv.RequiredValidator(
                      errorText: 'Email or mobile is required'), // Use prefix
                  ffv.EmailValidator(
                      errorText: 'Please enter a valid email'), // Use prefix
                ]),
                isRequired: true,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Tender Receive Via (Required)
              _buildDropdownField(
                name: 'tenderReceiveVia',
                label: 'Tender Receive Via',
                items: ['Email', 'WhatsApp', 'Telegram'],
                validator: ffv.RequiredValidator(
                    errorText: 'Please select a method'), // Use prefix
                isRequired: true,
              ),
              const SizedBox(height: 16),

              // WhatsApp/Telegram ID (Required)
              _buildTextField(
                name: 'contactId',
                label: 'WhatsApp Address/Telegram',
                validator: ffv.RequiredValidator(
                    errorText: 'Contact ID is required'), // Use prefix
                isRequired: true,
              ),
              const SizedBox(height: 16),

              // Category (Required)
              _buildDropdownField(
                name: 'category',
                label: 'Select Category',
                items: serviceNames,
                validator: ffv.RequiredValidator(
                    errorText: 'Please select a category'), // Use prefix
                isRequired: true,
              ),
              const SizedBox(height: 16),

              // Password (Required)
              _buildTextField(
                name: 'password',
                label: 'Create New Password / የሚስጥር ቁልፍ ያስገቡ *',
                validator: ffv.MultiValidator([
                  ffv.RequiredValidator(
                      errorText: 'Password is required'), // Use prefix
                  ffv.MinLengthValidator(6,
                      errorText:
                          'Password must be at least 6 characters'), // Use prefix
                ]),
                isRequired: true,
                obscureText: true,
              ),
              const SizedBox(height: 16),

              // Company Name (Optional)
              _buildTextField(
                name: 'companyName',
                label: 'Your Company Name (Optional)',
                isRequired: false,
              ),
              const SizedBox(height: 16),

              // TIN Number (Optional)
              _buildTextField(
                name: 'tinNumber',
                label: 'Your TIN Number (Optional)',
                isRequired: false,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),

              // Register Button
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Theme.of(context).secondaryHeaderColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
              const SizedBox(height: 16),

              // // Login Prompt
              // Center(
              //   child: TextButton(
              //     onPressed: () {},
              //     child: Text(
              //       'Do you have an account? Login',
              //       style: TextStyle(
              //         fontSize: 16,
              //         color: Theme.of(context).secondaryHeaderColor,
              //         decoration: TextDecoration.underline,
              //       ),
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 8),

              // SMS/Email Notification Text
              // const Text(
              //   'ከተመዘገቡ በኃላ የስልክ መልዕክት (SMS) ወይም ኢሜል ማየት አይርሱ',
              //   style: TextStyle(fontSize: 14, color: Colors.grey),
              //   textAlign: TextAlign.center,
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String name,
    required String label,
    ffv.FormFieldValidator<String>? validator, // Use prefix for validator
    bool isRequired = false,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FormBuilderTextField(
          name: name,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String name,
    required String label,
    required List<String> items,
    ffv.FormFieldValidator<String>? validator, // Use prefix for validator
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4), // Decreased height
        FormBuilderDropdown<String>(
          name: name,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          validator: validator,
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isSubmitting = true);

      final formData = _formKey.currentState!.value;
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final user = TenderUser(
        firstName: formData['firstName'],
        lastName: formData['lastName'],
        emailOrMobile: formData['emailOrMobile'],
        tenderReceiveVia: formData['tenderReceiveVia'],
        contactId: formData['contactId'],
        category: formData['category'],
        password: formData['password'],
        companyName: formData['companyName'],
        tinNumber: formData['tinNumber'],
      );

      if (userProvider.validateForm(
        firstName: user.firstName,
        lastName: user.lastName,
        emailOrMobile: user.emailOrMobile,
        tenderReceiveVia: user.tenderReceiveVia,
        contactId: user.contactId,
        category: user.category,
        password: user.password,
      )) {
        // userProvider.setUser(user);

        // Simulate API call or registration process
        await Future.delayed(const Duration(seconds: 2));

        if (context.mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          // Navigate to dashboard or subscription confirmation page
          // Navigator.pushNamed(context, '/dashboard');
        }
      } else {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please fill all required fields correctly.')),
        );
      }
    }
  }
}

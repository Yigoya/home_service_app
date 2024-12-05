import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:home_service_app/provider/auth_provider.dart';
import 'package:home_service_app/utils/elements.dart';
import 'package:home_service_app/widgets/custom_dropdown.dart';
import 'package:home_service_app/widgets/multi_select.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TechnicianRegistrationPage extends StatefulWidget {
  const TechnicianRegistrationPage({super.key});

  @override
  _TechnicianRegistrationPageState createState() =>
      _TechnicianRegistrationPageState();
}

class _TechnicianRegistrationPageState
    extends State<TechnicianRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _subCity, _wereda;
  List<int> _services = [];
  String? _documentsPath, _idCardPath, _profileImagePath;

  void handleSelectionChanged(List<int> selectedIds) {
    setState(() {
      _services = selectedIds;
    });
  }

  Future<void> _pickFile(String fileType) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (fileType == 'documents') _documentsPath = pickedFile.path;
        if (fileType == 'idCard') _idCardPath = pickedFile.path;
        if (fileType == 'profileImage') _profileImagePath = pickedFile.path;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      var formData = FormData.fromMap({
        'name': _nameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneController.text,
        'bio': _bioController.text,
        'services': _services.join(','),
        'subCity': _subCity ?? '',
        'wereda': _wereda ?? '',
        'password': _passwordController.text,
        if (_documentsPath != null)
          'documents': await MultipartFile.fromFile(_documentsPath!),
        if (_idCardPath != null)
          'idCardImage': await MultipartFile.fromFile(_idCardPath!),
        if (_profileImagePath != null)
          'profileImage': await MultipartFile.fromFile(_profileImagePath!),
      });

      for (var service in _services) {
        formData.fields.add(MapEntry('serviceIds', service.toString()));
      }

      await Provider.of<AuthenticationProvider>(context, listen: false)
          .registerTechnician(formData, context);
    }
  }

  bool isNext = false;

  Widget _buildNextButton() {
    return SimpleComponents.buildButton(
      isLoading: false,
      onTap: () {
        if (_formKey.currentState!.validate()) {
          setState(() {
            isNext = true;
          });
        }
      },
      buttonText: 'Next',
    );
  }

  Widget _buildFormPage1() {
    return Column(
      children: [
        const SizedBox(height: 36),
        Center(
          child: Text(
            AppLocalizations.of(context)!.technicianRegistration,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            AppLocalizations.of(context)!.fillDetailsToRegister,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 36),
        SimpleComponents.buildTextField(
          _nameController,
          'Name',
          AppLocalizations.of(context)!.enterYourName,
        ),
        const SizedBox(height: 8),
        SimpleComponents.buildTextField(
          _emailController,
          'Email',
          AppLocalizations.of(context)!.enterYourEmail,
          isEmail: true,
        ),
        const SizedBox(height: 8),
        SimpleComponents.buildTextField(
          _phoneController,
          'Phone Number',
          AppLocalizations.of(context)!.enterYourPhoneNumber,
          isPhone: true,
        ),
        const SizedBox(height: 8),
        SimpleComponents.buildTextField(
          _bioController,
          'Bio',
          AppLocalizations.of(context)!.enterYourBio,
          isLongText: true,
        ),
        const SizedBox(height: 24),
        _buildNextButton(),
      ],
    );
  }

  Widget _buildFormPage2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 36),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isNext = false;
                });
              },
              child: Row(
                children: [
                  Icon(Icons.arrow_back, color: Colors.blue),
                  SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.back,
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              AppLocalizations.of(context)!.almostThere,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          AppLocalizations.of(context)!.services,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        MultiSelectComponent(
          onSelectionChanged: handleSelectionChanged,
        ),
        const SizedBox(height: 16),
        CustomDropdown(
          items: const ["Bole", "Akaki", "Nifas Silk"],
          hint: AppLocalizations.of(context)!.selectYourSubCity,
          selectedValue: _subCity,
          onChanged: (value) => setState(() => _subCity = value),
        ),
        const SizedBox(height: 16),
        CustomDropdown(
          items: const ["01", "02", "03", "04", "05"],
          hint: AppLocalizations.of(context)!.selectYourWereda,
          selectedValue: _wereda,
          onChanged: (value) => setState(() => _wereda = value),
        ),
        _buildFileUploadButton(AppLocalizations.of(context)!.documents,
            _documentsPath, () => _pickFile('documents')),
        _buildFileUploadButton(AppLocalizations.of(context)!.idCard,
            _idCardPath, () => _pickFile('idCard')),
        _buildFileUploadButton('Profile Image', _profileImagePath,
            () => _pickFile('profileImage')),
        const SizedBox(height: 16),
        SimpleComponents.buildTextField(
          _passwordController,
          'Password',
          AppLocalizations.of(context)!.enterYourPassword,
          isPassword: true,
        ),
        SimpleComponents.buildTextField(
          _confirmPasswordController,
          AppLocalizations.of(context)!.confirmPassword,
          AppLocalizations.of(context)!.confirmPassword,
          isPassword: true,
        ),
        const SizedBox(height: 36),
        SimpleComponents.buildButton(
          isLoading: Provider.of<AuthenticationProvider>(context).isLoading,
          onTap: _submitForm,
          buttonText: 'Register',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              isNext ? _buildFormPage2() : _buildFormPage1(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadButton(
      String label, String? path, VoidCallback onTap) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              path != null
                  ? path.split('/').last
                  : AppLocalizations.of(context)!.upload,
            ),
          ),
        ),
      ],
    );
  }
}

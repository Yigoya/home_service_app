import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:home_service_app/provider/auth_provider.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/utils/elements.dart';
import 'package:home_service_app/widgets/custom_dropdown.dart';
import 'package:home_service_app/widgets/multi_select.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:home_service_app/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TechnicianRegistrationPage extends StatefulWidget {
  const TechnicianRegistrationPage({super.key});

  @override
  _TechnicianRegistrationPageState createState() =>
      _TechnicianRegistrationPageState();
}

class _TechnicianRegistrationPageState
    extends State<TechnicianRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
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
        'name': '${_firstNameController.text} ${_lastNameController.text}',
        'email': _emailController.text,
        'phoneNumber': '+251${_phoneController.text}',
        'bio': _bioController.text,
        'services': _services.join(','),
        'subcity': _subCity ?? '',
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
        buttonText: AppLocalizations.of(context)!.next,
        color: Theme.of(context).primaryColor);
  }

  Widget _buildFormPage1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.technicianRegistration,
            style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 0, 88, 22))),
        SizedBox(height: 8.h),
        Text(
          AppLocalizations.of(context)!.fillDetailsToRegister,
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 36.h),
        SimpleComponents.buildTextField(
          _firstNameController,
          AppLocalizations.of(context)!.firstName,
          AppLocalizations.of(context)!.enterYourName,
        ),
        SizedBox(height: 8.h),
        SimpleComponents.buildTextField(
          _lastNameController,
          AppLocalizations.of(context)!.lastName,
          AppLocalizations.of(context)!.enterYourName,
        ),
        SizedBox(height: 8.h),
        SimpleComponents.buildTextField(
          _emailController,
          AppLocalizations.of(context)!.email,
          AppLocalizations.of(context)!.enterYourEmail,
          isEmail: true,
        ),
        SizedBox(height: 8.h),
        SimpleComponents.buildTextField(
          _phoneController,
          AppLocalizations.of(context)!.phoneNumber,
          AppLocalizations.of(context)!.enterYourPhoneNumber,
          isPhone: true,
        ),
        SizedBox(height: 8.h),
        SimpleComponents.buildTextField(
          _bioController,
          AppLocalizations.of(context)!.tellUsAboutYourself,
          AppLocalizations.of(context)!.enterYourBio,
          isLongText: true,
        ),
        SizedBox(height: 24.h),
        // _buildNextButton(),
      ],
    );
  }

  Widget _buildFormPage2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SizedBox(height: 36.h),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     GestureDetector(
        //       onTap: () {
        //         setState(() {
        //           isNext = false;
        //         });
        //       },
        //       child: Row(
        //         children: [
        //           const Icon(Icons.arrow_back, color: Colors.blue),
        //           SizedBox(width: 4.w),
        //           Text(
        //             AppLocalizations.of(context)!.back,
        //             style: const TextStyle(
        //               color: Colors.blue,
        //               fontWeight: FontWeight.bold,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //     Text(
        //       AppLocalizations.of(context)!.almostThere,
        //       style: TextStyle(
        //         fontSize: 14.sp,
        //         fontWeight: FontWeight.bold,
        //         color: Colors.blue,
        //       ),
        //     ),
        //   ],
        // ),
        // SizedBox(height: 32.h),
        // Text(
        //   AppLocalizations.of(context)!.services,
        //   textAlign: TextAlign.left,
        //   style: TextStyle(
        //     fontWeight: FontWeight.w500,
        //     fontSize: 14.sp,
        //   ),
        // ),
        SizedBox(height: 8.h),
        MultiSelectComponent(
          onSelectionChanged: handleSelectionChanged,
        ),
        SizedBox(height: 16.h),
        CustomDropdown(
          items: Provider.of<HomeServiceProvider>(context)
              .subCitys(Localizations.localeOf(context)),
          hint: AppLocalizations.of(context)!.selectYourSubCity,
          selectedValue: _subCity,
          onChanged: (value) => setState(() => _subCity = value),
        ),
        SizedBox(height: 16.h),
        CustomDropdown(
          items: Provider.of<HomeServiceProvider>(context).weredas,
          hint: AppLocalizations.of(context)!.selectYourWereda,
          selectedValue: _wereda,
          onChanged: (value) => setState(() => _wereda = value),
        ),
        _buildFileUploadButton(AppLocalizations.of(context)!.documents,
            _documentsPath, () => _pickFile('documents')),
        _buildFileUploadButton(AppLocalizations.of(context)!.idCard,
            _idCardPath, () => _pickFile('idCard')),
        _buildFileUploadButton(AppLocalizations.of(context)!.profileImage,
            _profileImagePath, () => _pickFile('profileImage')),
        SizedBox(height: 16.h),
        SimpleComponents.buildTextField(
          _passwordController,
          AppLocalizations.of(context)!.password,
          AppLocalizations.of(context)!.enterYourPassword,
          isPassword: true,
        ),
        SizedBox(height: 16.h),
        SimpleComponents.buildTextField(
          _confirmPasswordController,
          AppLocalizations.of(context)!.confirmPassword,
          AppLocalizations.of(context)!.confirmPassword,
          isPassword: true,
        ),
        SizedBox(height: 36.h),
        SimpleComponents.buildButton(
          isLoading: Provider.of<AuthenticationProvider>(context).isLoading,
          onTap: _submitForm,
          buttonText: AppLocalizations.of(context)!.registerPrompt,
          color: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.signUp,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [_buildFormPage1(), _buildFormPage2()],
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadButton(
      String label, String? path, VoidCallback onTap) {
    return Row(
      children: [
        Expanded(
            child: Text(
          label,
          style: TextStyle(
              color: Colors.grey[800],
              fontSize: 18.sp,
              fontWeight: FontWeight.w500),
        )),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
            margin: EdgeInsets.only(top: 16.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              path != null
                  ? path.split('/').last
                  : AppLocalizations.of(context)!.upload,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

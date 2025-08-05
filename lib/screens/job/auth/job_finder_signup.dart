import 'package:flutter/material.dart';
import 'package:home_service_app/provider/auth_provider.dart';
import 'package:home_service_app/utils/elements.dart';
import 'package:provider/provider.dart';
import 'package:home_service_app/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/screens/job/auth/job_finder_login.dart';
import 'package:home_service_app/screens/job/create_job_seeker_profile.dart';

class JobFinderSignupPage extends StatefulWidget {
  const JobFinderSignupPage({super.key});

  @override
  _JobFinderSignupPageState createState() => _JobFinderSignupPageState();
}

class _JobFinderSignupPageState extends State<JobFinderSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _authenticating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signup(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final provider =
          Provider.of<AuthenticationProvider>(context, listen: false);
      final userId = await provider.jobFinderSignup(
        name: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
        context: context,
      );
      if (userId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CreateJobSeekerProfileScreen(
              userId: userId,
              onProfileCreated: () {
                Navigator.of(context)
                    .pop(); // Pops CreateJobSeekerProfileScreen
                Navigator.of(context)
                    .pop(); // Pops SignupScreen, returns to original
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthenticationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Job Finder Sign Up',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Job Finder Signup Message
                Container(
                  padding: EdgeInsets.all(16.w),
                  margin: EdgeInsets.only(bottom: 24.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue.shade700, size: 20),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'You need to be logged in to apply for this job',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Text("Hulu Moya",
                    style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).primaryColor)),
                SizedBox(height: 8.h),
                Text(
                  "Create your Job Finder Account",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 36.h),
                SimpleComponents.buildTextField(
                    _nameController, "Full Name", "Enter your full name"),
                SizedBox(height: 16.h),
                SimpleComponents.buildTextField(
                    _emailController,
                    AppLocalizations.of(context)!.email,
                    AppLocalizations.of(context)!.enterYourEmail,
                    isEmail: true),
                SizedBox(height: 16.h),
                SimpleComponents.buildTextField(_phoneController,
                    "Phone Number", "Enter your phone number"),
                SizedBox(height: 16.h),
                SimpleComponents.buildTextField(
                    _passwordController,
                    AppLocalizations.of(context)!.password,
                    AppLocalizations.of(context)!.enterYourPassword,
                    isPassword: true),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed:
                        provider.isLoading ? null : () => _signup(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: provider.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobFinderLoginPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

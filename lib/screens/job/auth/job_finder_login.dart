import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/screens/job/auth/job_finder_signup.dart';
import 'package:home_service_app/screens/job/core/constants/color.dart';
import 'package:home_service_app/screens/job/apply_screen.dart';
import 'package:home_service_app/screens/job/saved_jobs_screen.dart';
import 'package:home_service_app/screens/job/applications_screen.dart';
import 'package:home_service_app/screens/job/profile_screen.dart';
import 'package:home_service_app/screens/job/main_screen.dart';
import 'package:home_service_app/models/job_model.dart';
import 'package:home_service_app/provider/auth_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/models/login_source.dart';
import 'package:provider/provider.dart';
import 'package:home_service_app/utils/functions.dart';
import 'package:home_service_app/screens/job/auth/return_destination.dart';

class JobFinderLoginPage extends StatefulWidget {
  final ReturnDestination? returnDestination;
  final Map<String, dynamic>? returnData;

  const JobFinderLoginPage({
    super.key,
    this.returnDestination,
    this.returnData,
  });

  @override
  State<JobFinderLoginPage> createState() => _JobFinderLoginPageState();
}

class _JobFinderLoginPageState extends State<JobFinderLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider =
          Provider.of<AuthenticationProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        context: context,
        source: LoginSource.jobFinder,
      );

      // After successful login, navigate to intended destination
      if (mounted) {
        // Add a small delay to ensure login process completes
        await Future.delayed(Duration(milliseconds: 500));
        _navigateToIntendedDestination();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToIntendedDestination() {
    if (widget.returnDestination == null) {
      // Default navigation - go back
      Navigator.of(context).pop();
      return;
    }

    // For job seeker screens, we need to go back to the main navigation
    // and then navigate to the intended screen from there
    switch (widget.returnDestination!) {
      case ReturnDestination.applyJob:
        final job = widget.returnData?['job'] as JobModel?;
        if (job != null) {
          // For apply job, we can replace directly since it's a standalone screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ApplyScreen(job: job),
            ),
          );
        } else {
          // Fallback if no job data
          Navigator.of(context).pop();
        }
        break;
      case ReturnDestination.savedJobs:
        // Navigate to MainScreen with saved jobs tab (index 1)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainScreen(initialTabIndex: 1),
          ),
          (route) => false, // Remove all previous routes
        );
        break;
      case ReturnDestination.applications:
        // Navigate to MainScreen with applications tab (index 2)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainScreen(initialTabIndex: 2),
          ),
          (route) => false, // Remove all previous routes
        );
        break;
      case ReturnDestination.profile:
        // Navigate to MainScreen with profile tab (index 3)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainScreen(initialTabIndex: 3),
          ),
          (route) => false, // Remove all previous routes
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Login',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Sign in to continue',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 40.h),

              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30.h),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20.h),

              // Sign Up Link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to sign up page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobFinderSignupPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

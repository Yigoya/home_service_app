import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_service_app/main.dart';
import 'package:home_service_app/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String? token;
  const ForgotPasswordPage({super.key, this.token});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final PageController _pageController = PageController();
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.token != null) {
      _tokenController.text = widget.token!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.jumpToPage(1);
        setState(() {
          _currentPage = 1;
        });
      });
    }
  }

  void _nextPage() async {
    if (_currentPage == 0) {
      final res =
          await Provider.of<AuthenticationProvider>(context, listen: false)
              .requestPasswordReset(_emailController.text, context);
      if (res) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentPage++;
        });
      }
    } else if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage--;
      });
    }
  }

  void _resetPassword() {
    if (_tokenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Verification token is required!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    } else if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    } else if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 6 characters long!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Provider.of<AuthenticationProvider>(context, listen: false).resetPassword(
        _tokenController.text, _newPasswordController.text, context);
  }

  Widget _buildPageContent(BuildContext context, int index) {
    switch (index) {
      case 0:
        return _buildStepContent(
          context,
          title: "Enter Your Email",
          description:
              "We'll send you a verification token to reset your password.",
          child: TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: "Email or Phone",
              prefixIcon: Icon(Icons.email_outlined),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
          buttonText: "Send Token",
          onPressed: _nextPage,
        );

      case 1:
        return _buildStepContent(
          context,
          title: "Set New Password",
          description: "Enter a strong password and confirm it below.",
          child: Column(
            children: [
              TextField(
                controller: _tokenController,
                decoration: InputDecoration(
                  labelText: "Verification token from your email",
                  prefixIcon: Icon(Icons.verified_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: "New Password",
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                obscureText: true,
              ),
              SizedBox(height: 15.h),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                obscureText: true,
              ),
            ],
          ),
          buttonText: "Reset Password",
          onPressed: _resetPassword,
          isBackVisible: true,
        );
      default:
        return Container();
    }
  }

  Widget _buildStepContent(
    BuildContext context, {
    required String title,
    required String description,
    required Widget child,
    required String buttonText,
    required VoidCallback onPressed,
    bool isBackVisible = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10.h),
        Text(
          description,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30.h),
        child,
        SizedBox(height: 30.h),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r)),
            padding: EdgeInsets.symmetric(vertical: 15.h),
          ),
          child: Provider.of<AuthenticationProvider>(context).isLoading
              ? CircularProgressIndicator()
              : Text(buttonText, style: TextStyle(fontSize: 14.sp)),
        ),
        if (isBackVisible)
          TextButton(
            onPressed: _previousPage,
            child: Text(
              "Back",
              style: TextStyle(color: Colors.blueAccent, fontSize: 12.sp),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: Container(
          height: 500.h,
          padding: EdgeInsets.all(20.w),
          margin: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10.r,
                spreadRadius: 5.r,
              ),
            ],
          ),
          child: PageView.builder(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 2,
            itemBuilder: _buildPageContent,
          ),
        ),
      ),
    );
  }
}

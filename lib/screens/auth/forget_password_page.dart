import 'package:flutter/material.dart';
import 'package:home_service_app/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.passwordsDoNotMatch),
          backgroundColor: Colors.red,
        ),
      );
      return;
    } else if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.passwordMustBeAtLeast6Characters),
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
          title: AppLocalizations.of(context)!.enterYourEmailPrompt,
          description: AppLocalizations.of(context)!.sendVerificationToken,
          child: TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.email,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: const BorderSide(
                  color: Colors.blue,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: const BorderSide(
                  color: Colors.blue,
                  width: 2.0,
                ),
              ),
              labelStyle: TextStyle(
                color: Color.fromARGB(255, 0, 88, 22),
                fontSize: 18.sp,
              ),
            ),
          ),
          buttonText: AppLocalizations.of(context)!.sendToken,
          onPressed: _nextPage,
        );

      case 1:
        return _buildStepContent(
          context,
          title: AppLocalizations.of(context)!.setNewPassword,
          description: AppLocalizations.of(context)!.enterStrongPassword,
          child: Column(
            children: [
              TextField(
                controller: _tokenController,
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.verificationTokenFromEmail,
                  prefixIcon: const Icon(Icons.verified_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.newPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                obscureText: true,
              ),
              SizedBox(height: 15.h),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.confirmPasswordPrompt,
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                obscureText: true,
              ),
            ],
          ),
          buttonText: AppLocalizations.of(context)!.resetPassword,
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
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r)),
            padding: EdgeInsets.symmetric(vertical: 15.h),
          ),
          child: Provider.of<AuthenticationProvider>(context).isLoading
              ? const CircularProgressIndicator()
              : Text(buttonText,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 18.sp)),
        ),
        if (isBackVisible)
          TextButton(
            onPressed: _previousPage,
            child: Text(
              AppLocalizations.of(context)!.backPrompt,
              style: TextStyle(color: Colors.blueAccent, fontSize: 16.sp),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0.h),
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2,
            itemBuilder: _buildPageContent,
          ),
        ),
      ),
    );
  }
}

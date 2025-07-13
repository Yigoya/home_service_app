import 'package:flutter/material.dart';
import 'package:home_service_app/provider/auth_provider.dart';
import 'package:home_service_app/utils/elements.dart';
import 'package:provider/provider.dart';
import 'package:home_service_app/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _authenticating = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signup(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final provider =
          Provider.of<AuthenticationProvider>(context, listen: false);
      await provider.signup(
        name: '${_firstNameController.text} ${_lastNameController.text}',
        email: _emailController.text,
        phoneNumber: '+251${_phoneController.text}',
        password: _passwordController.text,
        context: context,
      );
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
          AppLocalizations.of(context)!.signUp,
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
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hulu Moya",
                    style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).primaryColor)),
                SizedBox(height: 8.h),
                Text(
                  AppLocalizations.of(context)!.joinUs,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 36.h),
                SimpleComponents.buildTextField(
                    _firstNameController,
                    AppLocalizations.of(context)!.firstName,
                    AppLocalizations.of(context)!.enterYourName),
                SizedBox(height: 16.h),
                SimpleComponents.buildTextField(
                    _lastNameController,
                    AppLocalizations.of(context)!.lastName,
                    AppLocalizations.of(context)!.enterYourName),
                SizedBox(height: 16.h),
                SimpleComponents.buildTextField(
                    _emailController,
                    AppLocalizations.of(context)!.email,
                    AppLocalizations.of(context)!.enterYourEmail,
                    isEmail: true),
                SizedBox(height: 16.h),
                SimpleComponents.buildTextField(
                    _phoneController,
                    AppLocalizations.of(context)!.phoneNumber,
                    AppLocalizations.of(context)!.enterYourPhoneNumber,
                    isPhone: true),
                SizedBox(height: 16.h),
                SimpleComponents.buildTextField(
                    _passwordController,
                    AppLocalizations.of(context)!.password,
                    AppLocalizations.of(context)!.enterYourPassword,
                    isPassword: true),
                SizedBox(height: 36.h),
                SimpleComponents.buildButton(
                    isLoading: provider.isLoading,
                    onTap: () => _signup(context),
                    buttonText: AppLocalizations.of(context)!.signUp,
                    color: Theme.of(context).primaryColor),
                if (provider.errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      provider.errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 12.sp),
                    ),
                  ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.haveAnAccount,
                        style: TextStyle(fontSize: 14.sp)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(
                        AppLocalizations.of(context)!.logInPrompt,
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                        child: Divider(
                      height: 2.5.h,
                      color: Colors.grey,
                    )),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(AppLocalizations.of(context)!.orSignInWith,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500)),
                    ),
                    Expanded(child: Divider(height: 2.5.h, color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: !_authenticating
                      ? () async {
                          setState(() {
                            _authenticating = true;
                          });
                          await Provider.of<AuthenticationProvider>(context,
                                  listen: false)
                              .handleGoogleSignIn(context);
                          setState(() {
                            _authenticating = false;
                          });
                        }
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                      ),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: !_authenticating
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/google.png',
                                width: 20.w,
                                height: 20.h,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                AppLocalizations.of(context)!.signInWithGoogle,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

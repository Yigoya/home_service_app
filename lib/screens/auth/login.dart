import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_service_app/provider/auth_provider.dart';
import 'package:home_service_app/utils/elements.dart';
import 'package:home_service_app/utils/route_generator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user = FirebaseAuth.instance.currentUser;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      if (mounted) {
        setState(() {
          _user = event;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final provider =
          Provider.of<AuthenticationProvider>(context, listen: false);
      await provider.login(
        email: _emailController.text.trim(),
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 46.h,
                  ),
                  Text(AppLocalizations.of(context)!.welcomeBack,
                      style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue)),
                  SizedBox(height: 8.h),
                  Text(AppLocalizations.of(context)!.loginToYourAccount,
                      style: TextStyle(fontSize: 18.sp, color: Colors.grey)),
                  SizedBox(height: 32.h),
                  SimpleComponents.buildTextField(_emailController, "Email",
                      AppLocalizations.of(context)!.enterYourEmail,
                      isEmail: true),
                  SizedBox(height: 16.h),
                  SimpleComponents.buildTextField(
                      _passwordController,
                      "Password",
                      AppLocalizations.of(context)!.enterYourPassword,
                      isPassword: true),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, RouteGenerator.forgotPasswordPage);
                          },
                          child: Text(
                              AppLocalizations.of(context)!.forgotPassword,
                              style: TextStyle(
                                  color: Colors.blue, fontSize: 16.sp))),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  SimpleComponents.buildButton(
                      isLoading: provider.isLoading,
                      onTap: () => _login(context),
                      buttonText: 'Login'),
                  if (provider.errorMessage != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        provider.errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: 14.sp),
                      ),
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
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: !_authenticating
                            ? () async {
                                setState(() {
                                  _authenticating = true;
                                });
                                await Provider.of<AuthenticationProvider>(
                                        context,
                                        listen: false)
                                    .handleGoogleSignIn(context);
                                setState(() {
                                  _authenticating = false;
                                });
                              }
                            : null,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 32.w, vertical: 16.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(32.r),
                          ),
                          child: !_authenticating
                              ? Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/google.png',
                                      width: 20.w,
                                      height: 20.h,
                                    ),
                                    SizedBox(width: 12.w),
                                    Text(
                                      "Google",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.sp),
                                    ),
                                  ],
                                )
                              : CircularProgressIndicator(),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 32.w, vertical: 16.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(32.r),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/facebook.png',
                                width: 20.w,
                                height: 20.h,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Facebook",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 64.h),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                          context, '/signup'); // Navigate to Signup page
                    },
                    child: RichText(
                      text: TextSpan(
                          text: AppLocalizations.of(context)!.dontHaveAccount,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 14.sp),
                          children: [
                            TextSpan(
                              text: "Sign Up",
                              style: TextStyle(
                                  color: Colors.blue, fontSize: 14.sp),
                            ),
                          ]),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context,
                          '/register_technician'); // Navigate to Register Technician page
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(32.r),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.registerAsTechnician,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, String?>> _collectUserDetails(
    BuildContext context, {
    required bool missingName,
    required bool missingEmail,
    required bool missingPhoneNumber,
  }) async {
    final Map<String, String?> userDetails = {
      "name": null,
      "email": null,
      "phoneNumber": null
    };

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        final TextEditingController nameController = TextEditingController();
        final TextEditingController emailController = TextEditingController();
        final TextEditingController phoneController = TextEditingController();

        return AlertDialog(
          title: const Text('Complete Your Details'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (missingName)
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                if (missingEmail)
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty ||
                          !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                if (missingPhoneNumber)
                  TextFormField(
                    controller: phoneController,
                    decoration:
                        const InputDecoration(labelText: 'Phone Number'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  userDetails['name'] = nameController.text.trim();
                  userDetails['email'] = emailController.text.trim();
                  userDetails['phoneNumber'] = phoneController.text.trim();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    return userDetails;
  }

//   Future<void> handleFacebookSignIn() async {
//   try {
//     // Step 1: Trigger Facebook login
//     final LoginResult result = await FacebookAuth.instance.login();

//     // Step 2: Check the login result
//     if (result.status == LoginStatus.success) {
//       // Obtain the access token from Facebook
//       final AccessToken? accessToken = result.accessToken;

//       if (accessToken != null) {
//         // Step 3: Create a credential for Firebase
//         final AuthCredential credential = FacebookAuthProvider.credential(
//           accessToken.token,
//         );

//         // Step 4: Sign in with Firebase
//         UserCredential userCredential =
//             await FirebaseAuth.instance.signInWithCredential(credential);

//         // Step 5: Get the signed-in user
//         User? user = userCredential.user;

//         if (user != null) {
//           print("Facebook Sign-In successful!");
//           print("User Name: ${user.displayName}");
//           print("User Email: ${user.email}");
//           print("User Photo URL: ${user.photoURL}");
//         }
//       }
//     } else if (result.status == LoginStatus.cancelled) {
//       print("Facebook Sign-In cancelled by user.");
//     } else {
//       print("Facebook Sign-In failed: ${result.message}");
//     }
//   } catch (e) {
//     print("Error during Facebook Sign-In: $e");
//   }
// }
}

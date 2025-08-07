import 'dart:ui'; // Add this import for the BackdropFilter
import 'package:flutter/material.dart';
import 'package:home_service_app/models/login_source.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/auth/login.dart';
import 'package:home_service_app/screens/tender/subscription_page.dart';
import 'package:provider/provider.dart';

class LoginBlur extends StatefulWidget {
  final Widget child;
  final Size? size;
  final void Function() getSize;

  const LoginBlur(
      {Key? key,
      required this.child,
      required this.size,
      required this.getSize})
      : super(key: key);

  @override
  State<LoginBlur> createState() => _LoginBlurState();
}

class _LoginBlurState extends State<LoginBlur> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      widget.getSize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (user != null) {
      return widget.child;
    }

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: widget.size != null ? widget.size!.height + 90 : 380),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Detailed Description",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "To view the detailed description of this tender, please log in. "
                "Logging in will provide you with access to all the necessary information, "
                "including contact details, document downloads, and more.",
                style: const TextStyle(color: Colors.black87, fontSize: 14),
              ),
            ],
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: Container(
            width: double.infinity,
            height: 216,
            margin: EdgeInsets.only(
                top: widget.size != null ? widget.size!.height + 20 : 310,
                left: 16,
                right: 16),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8)),
                  ),
                  child: Text(
                    "Organization Details, Notice Details and Documents",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginPage(
                                source: LoginSource.tender,
                              )),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 52),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

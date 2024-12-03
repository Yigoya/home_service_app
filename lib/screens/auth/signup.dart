import 'package:flutter/material.dart';
import 'package:home_service_app/provider/auth_provider.dart';
import 'package:home_service_app/utils/elements.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

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
      await provider.signup(
        name: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  AppLocalizations.of(context)!.createAccount,
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.joinUs,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SimpleComponents.buildTextField(_nameController, "Name",
                    AppLocalizations.of(context)!.enterYourName),
                const SizedBox(height: 16),
                SimpleComponents.buildTextField(_emailController, "Email",
                    AppLocalizations.of(context)!.enterYourEmail,
                    isEmail: true),
                const SizedBox(height: 16),
                SimpleComponents.buildTextField(
                    _phoneController,
                    "Phone Number",
                    AppLocalizations.of(context)!.enterYourPhoneNumber,
                    isPhone: true),
                const SizedBox(height: 16),
                SimpleComponents.buildTextField(_passwordController, "Password",
                    AppLocalizations.of(context)!.enterYourPassword,
                    isPassword: true),
                const SizedBox(height: 36),
                SimpleComponents.buildButton(
                    isLoading: provider.isLoading,
                    onTap: () => _signup(context),
                    buttonText: 'Sign Up'),
                if (provider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
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

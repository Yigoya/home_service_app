import 'package:flutter/material.dart';
import 'package:home_service_app/provider/form_provider.dart';
import 'package:home_service_app/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<FormProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Container(
          padding: EdgeInsets.all(16.0.w),
          margin: EdgeInsets.only(
              top: 52.h, left: 16.w, right: 16.w, bottom: 400.h),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 36.h),
                Text("Contact us",
                    style: TextStyle(
                        fontSize: 22.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 16.h),
                CustomTextField(
                  label: AppLocalizations.of(context)!.name,
                  hint: AppLocalizations.of(context)!.enterYourNamePrompt,
                  controller: formProvider.nameController,
                  errorMsg: AppLocalizations.of(context)!.nameIsRequired,
                ),
                CustomTextField(
                  label: "Email",
                  hint: AppLocalizations.of(context)!.enterYourEmailPrompt,
                  controller: formProvider.emailController,
                  keyboardType: TextInputType.emailAddress,
                  errorMsg: AppLocalizations.of(context)!.emailIsRequired,
                ),
                CustomTextField(
                  label: "Phone Number",
                  hint: "Enter your phone number",
                  controller: formProvider.phoneController,
                  keyboardType: TextInputType.phone,
                  errorMsg: AppLocalizations.of(context)!.phoneNumberIsRequired,
                ),
                CustomTextField(
                  label: "Message",
                  hint: AppLocalizations.of(context)!.writeYourMessagePrompt,
                  controller: formProvider.messageController,
                  errorMsg: "Please put you message",
                  maxLines: 4,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.blue),
                      foregroundColor: WidgetStateProperty.all(Colors.white)),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      formProvider.submitContactForm(context);
                    }
                  },
                  child: formProvider.isLoading
                      ? const CircularProgressIndicator.adaptive(
                          backgroundColor: Colors.white,
                        )
                      : Text(AppLocalizations.of(context)!.submitPrompt),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

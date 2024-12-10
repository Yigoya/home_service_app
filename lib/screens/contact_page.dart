import 'package:flutter/material.dart';
import 'package:home_service_app/provider/form_provider.dart';
import 'package:home_service_app/widgets/custom_textfield.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<FormProvider>(context);
    final _formKey = GlobalKey<FormState>();
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
                        fontSize: 24.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 16.h),
                CustomTextField(
                  label: "Name",
                  hint: "Enter your name",
                  controller: formProvider.nameController,
                  errorMsg: "Name is required",
                ),
                CustomTextField(
                  label: "Email",
                  hint: "Enter your email",
                  controller: formProvider.emailController,
                  keyboardType: TextInputType.emailAddress,
                  errorMsg: "Email is required",
                ),
                CustomTextField(
                  label: "Phone Number",
                  hint: "Enter your phone number",
                  controller: formProvider.phoneController,
                  keyboardType: TextInputType.phone,
                  errorMsg: "Phone number is required",
                ),
                CustomTextField(
                  label: "Message",
                  hint: "Write your message",
                  controller: formProvider.messageController,
                  errorMsg: "Please put you message",
                  maxLines: 4,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      foregroundColor: MaterialStateProperty.all(Colors.white)),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      formProvider.submitContactForm(context);
                    }
                  },
                  child: formProvider.isLoading
                      ? const CircularProgressIndicator.adaptive(
                          backgroundColor: Colors.white,
                        )
                      : const Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

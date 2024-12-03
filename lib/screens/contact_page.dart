import 'package:flutter/material.dart';
import 'package:home_service_app/provider/form_provider.dart';
import 'package:home_service_app/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<FormProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Contact us",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CustomTextField(
              label: "Name",
              hint: "Enter your name",
              controller: formProvider.nameController,
            ),
            CustomTextField(
              label: "Email",
              hint: "Enter your email",
              controller: formProvider.emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            CustomTextField(
              label: "Phone Number",
              hint: "Enter your phone number",
              controller: formProvider.phoneController,
              keyboardType: TextInputType.phone,
            ),
            CustomTextField(
              label: "Message",
              hint: "Write your message",
              controller: formProvider.messageController,
            ),
            ElevatedButton(
              onPressed: () => formProvider.submitContactForm(),
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}

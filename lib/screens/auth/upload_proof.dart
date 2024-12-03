import 'package:flutter/material.dart';
import 'package:home_service_app/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadProofPagee extends StatelessWidget {
  final picker = ImagePicker();

  UploadProofPagee({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Provider.of<AuthenticationProvider>(context, listen: false)
          .uploadTicket(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registration Fee Transfer')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'For registration fee transfer\n500 birr',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _pickImage(context),
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload image'),
              ),
              const SizedBox(height: 20),
              Consumer<AuthenticationProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton(
                    onPressed: provider.ticketImage != null
                        ? () {
                            // Handle submission logic
                          }
                        : null,
                    child: const Text('Submit'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

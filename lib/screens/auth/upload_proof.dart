import 'package:flutter/material.dart';
import 'package:home_service_app/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'For registration fee transfer\n500 birr',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.sp),
              ),
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed: () => _pickImage(context),
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload image'),
              ),
              SizedBox(height: 20.h),
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

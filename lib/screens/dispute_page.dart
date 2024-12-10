import 'package:flutter/material.dart';
import 'package:home_service_app/provider/form_provider.dart';
import 'package:home_service_app/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DisputePage extends StatefulWidget {
  final int bookingId;

  const DisputePage({super.key, required this.bookingId});
  @override
  State<DisputePage> createState() => _DisputePageState();
}

class _DisputePageState extends State<DisputePage> {
  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<FormProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Dispute')),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Dispute",
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            CustomTextField(
              label: "Reason",
              hint: "Enter your reason",
              controller: formProvider.reasonController,
              errorMsg: "Please enter your reason",
            ),
            CustomTextField(
              label: "State your dispute",
              hint: "Describe your dispute",
              controller: formProvider.disputeDescriptionController,
              errorMsg: "Please describe your issue your reason",
            ),
            formProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () => {
                      formProvider.submitDisputeForm(widget.bookingId, context),
                      Navigator.pop(context)
                    },
                    child: const Text("Submit"),
                  ),
          ],
        ),
      ),
    );
  }
}

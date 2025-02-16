import 'package:flutter/material.dart';
import 'package:home_service_app/provider/form_provider.dart';
import 'package:home_service_app/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DisputePage extends StatefulWidget {
  final int bookingId;

  const DisputePage({super.key, required this.bookingId});
  @override
  State<DisputePage> createState() => _DisputePageState();
}

class _DisputePageState extends State<DisputePage> {
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<FormProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Container(
        padding: EdgeInsets.all(16.0.w),
        margin:
            EdgeInsets.only(top: 64.h, left: 16.w, right: 16.w, bottom: 400.h),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Dispute",
                  style:
                      TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              CustomTextField(
                label: AppLocalizations.of(context)!.reason,
                hint: "Enter your reason",
                controller: formProvider.reasonController,
                errorMsg: AppLocalizations.of(context)!.pleaseEnterYourReason,
              ),
              CustomTextField(
                label: AppLocalizations.of(context)!.stateYourDisputePrompt,
                hint: AppLocalizations.of(context)!.describeYourDisputePrompt,
                controller: formProvider.disputeDescriptionController,
                errorMsg: "Please describe your issue your reason",
              ),
              formProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.blue),
                          foregroundColor:
                              WidgetStateProperty.all(Colors.white)),
                      onPressed: () => {
                        if (formKey.currentState!.validate())
                          formProvider.submitDisputeForm(
                              widget.bookingId, context),
                        Navigator.pop(context)
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
    );
  }
}

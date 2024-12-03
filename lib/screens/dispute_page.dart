import 'package:flutter/material.dart';
import 'package:home_service_app/provider/form_provider.dart';
import 'package:home_service_app/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Dispute",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CustomTextField(
              label: "Reason",
              hint: "Enter your reason",
              controller: formProvider.reasonController,
            ),
            CustomTextField(
              label: "State your dispute",
              hint: "Describe your dispute",
              controller: formProvider.disputeDescriptionController,
            ),
            Provider.of<FormProvider>(context).isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () => {
                      formProvider.submitDisputeForm(widget.bookingId),
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

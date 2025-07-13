import 'package:flutter/material.dart';
import 'package:home_service_app/screens/job/core/constants/color.dart';

class ApplyScreen extends StatefulWidget {
  const ApplyScreen({super.key});

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final TextEditingController _coverLetterController = TextEditingController();
  final int _coverLetterMax = 2000;

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kCardColorLight,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.close, color: kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('Apply',
            style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Image.asset('assets/images/profile.png',
                          width: 40, height: 40, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Software Engineer',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22)),
                      const SizedBox(height: 2),
                      Text('Acme Inc.',
                          style: TextStyle(color: kGrey600, fontSize: 16)),
                      const SizedBox(height: 14),
                    ],
                  ),
                ],
              ),

              SizedBox(
                height: 30,
              ),

              // Job Card
              const Text('Job Summary',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: kCardColorLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: kGrey300),
                ),
                child: Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.work_outline, size: 18, color: kGrey600),
                          const SizedBox(width: 8),
                          const Text('Full-time',
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 18, color: kGrey600),
                          const SizedBox(width: 8),
                          const Text('Remote', style: TextStyle(fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.attach_money, size: 18, color: kGrey600),
                          const SizedBox(width: 8),
                          const Text('	100K - \$120K',
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 18, color: kGrey600),
                          const SizedBox(width: 8),
                          const Text('Posted 2d ago',
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Resume
              const Text('Your Resume',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: kCardColorLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kGrey300),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.insert_drive_file,
                          color: kPrimaryColor, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('my_resume_final.pdf',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16)),
                          SizedBox(height: 2),
                          Text('Uploaded on 12/04/24',
                              style: TextStyle(color: kGrey600, fontSize: 13)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: null,
                      child: Text('Update',
                          style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Cover Letter
              const Text('Cover Letter (Required)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: kCardColorLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kGrey300),
                ),
                child: Stack(
                  children: [
                    TextField(
                      controller: _coverLetterController,
                      maxLines: 8,
                      maxLength: _coverLetterMax,
                      decoration: const InputDecoration(
                        hintText:
                            'Explain why you’re a great fit for this role...',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        counterText: '',
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 8,
                      child: Text(
                        '${_coverLetterController.text.length} / $_coverLetterMax',
                        style: TextStyle(color: kGrey600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Submit Button
              SaveButton(
                text: 'Submit Application',
                onPressed: () {},
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

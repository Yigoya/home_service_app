import 'package:flutter/material.dart';
import 'package:home_service_app/screens/job/core/constants/color.dart';
import 'package:home_service_app/screens/job/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Static storage for user preferences (fallback when SharedPreferences fails)
class UserPreferences {
  static List<String> jobTypes = [];
  static String? jobRole;
  static List<String> industries = [];
  static bool hasPreferences = false;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  List<String> _selectedJobTypes = [];
  String? _jobRole;
  List<String> _selectedIndustries = [];

  final List<String> jobTypes = [
    'Full-time',
    'Part-time',
    'Internship',
    'Freelance',
    'Contract',
  ];

  final List<String> industries = [
    'IT',
    'Healthcare',
    'Education',
    'Finance',
    'Retail',
  ];

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Finish onboarding and navigate to main screen with filters
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    // Create onboarding data to pass to main screen
    final onboardingData = {
      'selectedJobTypes': _selectedJobTypes,
      'jobRole': _jobRole,
      'selectedIndustries': _selectedIndustries,
    };

    // Save to static storage as primary method
    UserPreferences.jobTypes = _selectedJobTypes;
    UserPreferences.jobRole = _jobRole;
    UserPreferences.industries = _selectedIndustries;
    UserPreferences.hasPreferences = true;
    print('Saved preferences to static storage');

    // Try to save preferences to SharedPreferences as backup
    try {
      // Add a small delay to ensure platform is ready
      await Future.delayed(const Duration(milliseconds: 100));

      // Save user preferences to SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // Save job types
      if (_selectedJobTypes.isNotEmpty) {
        await prefs.setStringList('onboarding_job_types', _selectedJobTypes);
      }

      // Save job role
      if (_jobRole != null && _jobRole!.trim().isNotEmpty) {
        await prefs.setString('onboarding_job_role', _jobRole!);
      }

      // Save industries
      if (_selectedIndustries.isNotEmpty) {
        await prefs.setStringList('onboarding_industries', _selectedIndustries);
      }

      // Mark onboarding as completed
      await prefs.setBool('onboarding_completed', true);

      print('Successfully saved onboarding preferences to SharedPreferences');
    } catch (e) {
      print('Error saving onboarding preferences to SharedPreferences: $e');
      // Continue without SharedPreferences - static storage is already set
    }

    // Navigate to main screen and replace the current route
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MainScreen(onboardingData: onboardingData),
      ),
    );
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 32,
            height: 6,
            decoration: BoxDecoration(
              color: _currentStep == index
                  ? kPrimaryColor
                  : kPrimaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.work_outline, size: 64, color: kPrimaryColor),
        const SizedBox(height: 24),
        const Text('Step 1 of 3', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        const Text(
          'What type of job are you looking for?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'You can select multiple options',
          style: TextStyle(color: Colors.grey, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...jobTypes.map(
          (type) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
            child: CheckboxListTile(
              value: _selectedJobTypes.contains(type),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedJobTypes.add(type);
                  } else {
                    _selectedJobTypes.remove(type);
                  }
                });
              },
              title: Text(type, style: const TextStyle(fontSize: 18)),
              controlAffinity: ListTileControlAffinity.leading,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              activeColor: kPrimaryColor,
              tileColor: kCardColorLight,
              checkColor: Colors.white,
              side: BorderSide(color: kPrimaryColor, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 32),
        SaveButton(
          text: 'Next',
          onPressed: _selectedJobTypes.isNotEmpty ? _nextStep : null,
          height: 50,
        ),
        TextButton(
          onPressed: _nextStep,
          child: const Text(
            'Skip for now',
            style: TextStyle(color: kPrimaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.sentiment_satisfied_alt,
          size: 64,
          color: kPrimaryColor,
        ),
        const SizedBox(height: 24),
        _buildProgress(),
        const Text('Step 2 of 3', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        const Text(
          'What’s your preferred job role or field?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'e.g., Software Engineer',
              filled: true,
              fillColor: kPrimaryColor.withOpacity(0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (val) => setState(() => _jobRole = val),
          ),
        ),
        const SizedBox(height: 32),
        SaveButton(
          text: 'Next',
          onPressed: (_jobRole != null && _jobRole!.trim().isNotEmpty)
              ? _nextStep
              : null,
          height: 50,
        ),
        TextButton(
          onPressed: _nextStep,
          child: const Text(
            'Skip for now',
            style: TextStyle(color: kPrimaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        _buildProgress(),
        const Text('Step 3 of 3', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        // Avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kPrimaryColor.withOpacity(0.1),
            image: const DecorationImage(
              image: AssetImage('assets/images/profile.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Which industries are you most interested in?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...industries.map(
          (industry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
            child: CheckboxListTile(
              value: _selectedIndustries.contains(industry),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedIndustries.add(industry);
                  } else {
                    _selectedIndustries.remove(industry);
                  }
                });
              },
              title: Text(industry, style: const TextStyle(fontSize: 18)),
              controlAffinity: ListTileControlAffinity.leading,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              activeColor: kPrimaryColor,
              tileColor: kCardColorLight,
              checkColor: Colors.white,
              side: BorderSide(color: kPrimaryColor, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 32),
        SaveButton(
          text: 'Next',
          onPressed: _selectedIndustries.isNotEmpty ? _nextStep : null,
          height: 50,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: _currentStep == 0
                      ? _buildStep1()
                      : _currentStep == 1
                          ? _buildStep2()
                          : _buildStep3(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

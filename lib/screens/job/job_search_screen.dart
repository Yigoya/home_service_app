import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/screens/job/apply_screen.dart';
import 'package:home_service_app/screens/job/core/constants/color.dart';
import 'package:home_service_app/screens/job/job_details_screen.dart';
import 'package:home_service_app/screens/job/profile_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:home_service_app/models/job_model.dart';
import 'package:home_service_app/provider/job_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/widgets/bottom_navigation.dart';

// Static storage for user preferences (fallback when SharedPreferences fails)
class UserPreferences {
  static List<String> jobTypes = [];
  static String? jobRole;
  static List<String> industries = [];
  static bool hasPreferences = false;
}

class JobSearchScreen extends StatefulWidget {
  final Map<String, dynamic>? onboardingData;

  const JobSearchScreen({super.key, this.onboardingData});

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  // Search controller
  final TextEditingController _searchController = TextEditingController();
  // Speech to text
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';
  // Filter state
  String? _selectedJobType;
  String? _selectedLocation;
  String? _selectedCategory;
  String? _selectedDatePosted;
  // User preferences from SharedPreferences
  List<String> _userJobTypes = [];
  String? _userJobRole;
  List<String> _userIndustries = [];

  @override
  void initState() {
    super.initState();
    // Load user preferences from multiple sources
    _loadUserPreferences();
    // Initialize speech recognition after a short delay to ensure proper setup
    Future.delayed(const Duration(milliseconds: 500), () {
      _initSpeech();
    });
    // Fetch jobs from API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<JobProvider>().fetchJobs();
      }
    });
  }

  Future<void> _loadUserPreferences() async {
    // First, try to load from static storage (if available from onboarding)
    if (UserPreferences.hasPreferences) {
      setState(() {
        _userJobTypes = UserPreferences.jobTypes;
        _userJobRole = UserPreferences.jobRole;
        _userIndustries = UserPreferences.industries;
      });
      print('Loaded preferences from static storage');
      return;
    }

    // Second, try to load from onboarding data passed through navigation
    if (widget.onboardingData != null) {
      final data = widget.onboardingData!;
      setState(() {
        _userJobTypes = List<String>.from(data['selectedJobTypes'] ?? []);
        _userJobRole = data['jobRole'];
        _userIndustries = List<String>.from(data['selectedIndustries'] ?? []);
      });
      print('Loaded preferences from onboarding data');
      return;
    }

    // Third, try to load from SharedPreferences
    try {
      await Future.delayed(const Duration(milliseconds: 200));

      final prefs = await SharedPreferences.getInstance();
      final isOnboardingCompleted =
          prefs.getBool('onboarding_completed') ?? false;

      if (isOnboardingCompleted) {
        setState(() {
          _userJobTypes = prefs.getStringList('onboarding_job_types') ?? [];
          _userJobRole = prefs.getString('onboarding_job_role');
          _userIndustries = prefs.getStringList('onboarding_industries') ?? [];
        });
        print('Successfully loaded user preferences from SharedPreferences');
      }
    } catch (e) {
      print('Error reading user preferences from SharedPreferences: $e');
      // Continue without preferences - will use default sorting
    }
  }

  int get _selectedFilterCount {
    int count = 0;
    if (_selectedJobType != null) count++;
    if (_selectedLocation != null) count++;
    if (_selectedCategory != null) count++;
    if (_selectedDatePosted != null) count++;
    return count;
  }

  List<JobModel> get _filteredJobs {
    final jobProvider = context.read<JobProvider>();
    return jobProvider.filteredJobs;
  }

  List<JobModel> get _sortedJobs {
    final jobProvider = context.read<JobProvider>();
    final filtered = jobProvider.filteredJobs;

    // Apply user preferences for relevance sorting
    if (_userJobTypes.isNotEmpty ||
        _userJobRole != null ||
        _userIndustries.isNotEmpty) {
      jobProvider.sortJobsByRelevance(
        userJobTypes: _userJobTypes,
        userJobRole: _userJobRole,
        userIndustries: _userIndustries,
      );
    }

    return filtered;
  }

  int get _filteredResultCount => _filteredJobs.length;

  int _getCurrentFilteredCount() {
    final jobProvider = context.read<JobProvider>();
    final allJobs = jobProvider.jobs;

    // Apply current filter selections to get a preview count
    return allJobs.where((job) {
      // Search query filter
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final matchesSearch = job.title.toLowerCase().contains(query) ||
            job.companyName.toLowerCase().contains(query) ||
            job.jobLocation.toLowerCase().contains(query) ||
            job.tags.any((tag) => tag.toLowerCase().contains(query));
        if (!matchesSearch) return false;
      }

      // Job type filter
      if (_selectedJobType != null && job.jobType != _selectedJobType) {
        return false;
      }

      // Location filter
      if (_selectedLocation != null && job.jobLocation != _selectedLocation) {
        return false;
      }

      // Category filter
      if (_selectedCategory != null && job.category != _selectedCategory) {
        return false;
      }

      // Date posted filter
      if (_selectedDatePosted != null) {
        final postedDate = DateTime.parse(job.postedDate);
        final now = DateTime.now();

        switch (_selectedDatePosted) {
          case 'Last 24 hours':
            if (now.difference(postedDate).inHours > 24) return false;
            break;
          case 'Last 7 days':
            if (now.difference(postedDate).inDays > 7) return false;
            break;
          case 'Last 30 days':
            if (now.difference(postedDate).inDays > 30) return false;
            break;
        }
      }

      return true;
    }).length;
  }

  String _sortBy = 'relevance';

  // ValueNotifier to trigger button rebuilds
  final ValueNotifier<int> _filterChangeNotifier = ValueNotifier(0);

  @override
  void dispose() {
    _searchController.dispose();
    _filterChangeNotifier.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (error) {
          print('Speech recognition error: $error');
          setState(() {
            _isListening = false;
          });
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
            });
          }
        },
        debugLogging: true,
      );
      setState(() {});
    } catch (e) {
      print('Speech recognition initialization failed: $e');
      setState(() {
        _speechEnabled = false;
      });
    }
  }

  void _showVoiceSearchHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mic, color: kPrimaryColor),
            SizedBox(width: 8),
            Text('Voice Search'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How to use voice search:'),
            SizedBox(height: 12),
            Text('• Tap the microphone icon'),
            Text('• Speak clearly about the job you\'re looking for'),
            Text(
                '• Examples: "software engineer", "remote jobs", "designer in New York"'),
            Text('• The search will automatically update as you speak'),
            SizedBox(height: 12),
            Text(
                'Note: Make sure to grant microphone permission when prompted.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedJobType = null;
      _selectedLocation = null;
      _selectedCategory = null;
      _selectedDatePosted = null;
      _searchController.clear();
    });
    context.read<JobProvider>().clearFilters();
  }

  Future<void> _startListening() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission is required for voice search'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Speech recognition is not available on this device. Please try again later.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_isListening) {
      await _stopListening();
      return;
    }

    setState(() {
      _isListening = true;
    });

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _lastWords = result.recognizedWords;
          if (result.finalResult) {
            _searchController.text = _lastWords;
            _applyFilters();
          }
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
      cancelOnError: true,
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.confirmation,
      ),
    );
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _applyFilters() {
    final jobProvider = context.read<JobProvider>();
    jobProvider.filterJobs(
      searchQuery: _searchController.text,
      jobType: _selectedJobType,
      location: _selectedLocation,
      category: _selectedCategory,
      datePosted: _selectedDatePosted,
    );
  }

  void _showSortOptions() {
    final RenderBox fabBox = context.findRenderObject() as RenderBox;
    final Size fabSize = fabBox.size;
    final double dialogWidth = MediaQuery.of(context).size.width * 0.5;
    final double dialogHeight = 120;
    final double bottomPadding = 145; // Height above floating buttons

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              left: (MediaQuery.of(context).size.width - dialogWidth) / 2,
              bottom: bottomPadding,
              child: Material(
                color: Colors.white,
                elevation: 12,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: dialogWidth,
                  height: dialogHeight,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Column(
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Sort by',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 5),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        minTileHeight: 0,
                        leading:
                            Icon(_sortBy == 'relevance' ? Icons.check : null),
                        title: const Text('Relevance'),
                        onTap: () {
                          setState(() => _sortBy = 'relevance');
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        minTileHeight: 0,
                        leading: Icon(_sortBy == 'date' ? Icons.check : null),
                        title: const Text('Date'),
                        onTap: () {
                          setState(() => _sortBy = 'date');
                          context
                              .read<JobProvider>()
                              .fetchJobs(sortBy: 'Newest');
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFilterOptions() {
    final jobProvider = context.read<JobProvider>();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filters',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        // Use StatefulBuilder to allow setModalState for local state updates
        return Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height,
            child: Material(
              color: Colors.white,
              elevation: 16,
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.horizontal(left: Radius.circular(24)),
              ),
              child: SafeArea(
                child: StatefulBuilder(
                  builder: (context, setModalState) {
                    return Column(
                      children: [
                        // Top bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Filters',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  setModalState(() {
                                    _selectedJobType = null;
                                    _selectedLocation = null;
                                    _selectedCategory = null;
                                    _selectedDatePosted = null;
                                  });
                                  _searchController.clear();
                                  setState(() {});
                                  jobProvider.clearFilters();
                                },
                                child: const Text('Clear',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 16)),
                              ),
                            ],
                          ),
                        ),
                        // Main filter expansion tiles
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            child: ListView(
                              children: [
                                if (_selectedFilterCount > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      '$_selectedFilterCount filter${_selectedFilterCount > 1 ? 's' : ''} selected',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: kPrimaryColor,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ExpansionTile(
                                  title: const Text('Job Type'),
                                  children: jobProvider.uniqueJobTypes
                                      .map((jobType) => RadioListTile<String>(
                                            activeColor: kPrimaryColor,
                                            title: Text(jobType),
                                            value: jobType,
                                            groupValue: _selectedJobType,
                                            onChanged: (value) {
                                              setModalState(() =>
                                                  _selectedJobType = value);
                                              setState(() {});
                                              _filterChangeNotifier.value++;
                                            },
                                          ))
                                      .toList(),
                                ),
                                ExpansionTile(
                                  title: const Text('Location'),
                                  children: jobProvider.uniqueLocations
                                      .map((location) => RadioListTile<String>(
                                            activeColor: kPrimaryColor,
                                            title: Text(location),
                                            value: location,
                                            groupValue: _selectedLocation,
                                            onChanged: (value) {
                                              setModalState(() =>
                                                  _selectedLocation = value);
                                              setState(() {});
                                              _filterChangeNotifier.value++;
                                            },
                                          ))
                                      .toList(),
                                ),
                                ExpansionTile(
                                  title: const Text('Category'),
                                  children: jobProvider.uniqueCategories
                                      .map((cat) => RadioListTile<String>(
                                            activeColor: kPrimaryColor,
                                            title: Text(cat),
                                            value: cat,
                                            groupValue: _selectedCategory,
                                            onChanged: (value) {
                                              setModalState(() =>
                                                  _selectedCategory = value);
                                              setState(() {});
                                              _filterChangeNotifier.value++;
                                            },
                                          ))
                                      .toList(),
                                ),
                                ExpansionTile(
                                  title: const Text('Date Posted'),
                                  children: [
                                    RadioListTile<String>(
                                      activeColor: kPrimaryColor,
                                      title: const Text('Last 24 hours'),
                                      value: 'Last 24 hours',
                                      groupValue: _selectedDatePosted,
                                      onChanged: (value) {
                                        setModalState(
                                            () => _selectedDatePosted = value);
                                        setState(() {});
                                        _filterChangeNotifier.value++;
                                      },
                                    ),
                                    RadioListTile<String>(
                                      activeColor: kPrimaryColor,
                                      title: const Text('Last 7 days'),
                                      value: 'Last 7 days',
                                      groupValue: _selectedDatePosted,
                                      onChanged: (value) {
                                        setModalState(
                                            () => _selectedDatePosted = value);
                                        setState(() {});
                                        _filterChangeNotifier.value++;
                                      },
                                    ),
                                    RadioListTile<String>(
                                      activeColor: kPrimaryColor,
                                      title: const Text('Last 30 days'),
                                      value: 'Last 30 days',
                                      groupValue: _selectedDatePosted,
                                      onChanged: (value) {
                                        setModalState(
                                            () => _selectedDatePosted = value);
                                        setState(() {});
                                        _filterChangeNotifier.value++;
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Bottom apply button
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: ValueListenableBuilder<int>(
                            valueListenable: _filterChangeNotifier,
                            builder: (context, value, child) {
                              return SaveButton(
                                text:
                                    'Apply Filter (${_getCurrentFilteredCount()} results)',
                                onPressed: () {
                                  _applyFilters();
                                  Navigator.pop(context);
                                },
                                height: 48,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.ease)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCardColorLight,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: kPrimaryColor,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Consumer<JobProvider>(
          builder: (context, jobProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30.r),
                          bottomRight: Radius.circular(30.r),
                        ),
                      ),
                      child: Column(children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    // Check if we can pop back, if not navigate to main app home
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.pop(context);
                                    } else {
                                      // Navigate to the main app's home screen
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const Navigation(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    Icons.arrow_back_ios_new,
                                    color: kTextOnPrimary,
                                  )),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Find jobs',
                                    style: TextStyle(
                                        color: kTextOnPrimary,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w900),
                                  ),
                                  Text(
                                    'Anytime, anywhere',
                                    style: TextStyle(
                                        color: kTextOnPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                              Spacer(),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.notifications_active_outlined,
                                  color: kTextOnPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: SizedBox(
                                  height: 45.h,
                                  child: TextField(
                                    controller: _searchController,
                                    autofocus:
                                        false, // Don't focus initially for any user
                                    onChanged: (value) {
                                      _applyFilters();
                                    },
                                    style: TextStyle(
                                      color: _isListening
                                          ? kTextPrimary
                                          : kTextOnPrimary,
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: _isListening
                                          ? 'Listening...'
                                          : 'Search For...',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w400,
                                        color: _isListening
                                            ? kTextPrimary.withOpacity(0.6)
                                            : kTextOnPrimary.withOpacity(0.7),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        size: 24.r,
                                        color: _isListening
                                            ? kTextPrimary.withOpacity(0.8)
                                            : kTextOnPrimary.withOpacity(0.8),
                                      ),
                                      suffixIcon:
                                          _searchController.text.isNotEmpty
                                              ? IconButton(
                                                  icon: Icon(
                                                    Icons.clear,
                                                    size: 24.r,
                                                    color: _isListening
                                                        ? kTextPrimary
                                                        : kTextOnPrimary,
                                                  ),
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    _applyFilters();
                                                  },
                                                )
                                              : IconButton(
                                                  icon: Icon(
                                                    _isListening
                                                        ? Icons.mic
                                                        : Icons
                                                            .keyboard_voice_outlined,
                                                    size: 24.r,
                                                    color: _isListening
                                                        ? kTextPrimary
                                                        : kTextOnPrimary
                                                            .withOpacity(0.8),
                                                  ),
                                                  onPressed: _startListening,
                                                ),
                                      filled: true,
                                      fillColor: _isListening
                                          ? kGrey100
                                          : kPrimaryColor.withOpacity(0.15),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                          // width: _isListening ? 2 : 0,
                                        ),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                          // width: _isListening ? 2 : 0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                          // width: _isListening ? 2 : 0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                          // width: _isListening ? 2 : 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ),
        
                    // Voice search help button
                    if (!_speechEnabled)
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 20.w)
                            .copyWith(top: 8.h),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: kWarningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: kWarningColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 16, color: kWarningColor),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Voice search is not available on this device',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: kWarningColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Show recognized text when listening
                    if (_isListening && _lastWords.isNotEmpty)
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 20.w)
                            .copyWith(top: 8.h),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: kPrimaryColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.mic, size: 16, color: kPrimaryColor),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                _lastWords,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: kPrimaryColor,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10.h),
                // Clear filters button
                if (_selectedFilterCount > 0 || _searchController.text.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w)
                        .copyWith(bottom: 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.filter_list,
                                    size: 16, color: kPrimaryColor),
                                SizedBox(width: 6.w),
                                Text(
                                  '${_selectedFilterCount + (_searchController.text.isNotEmpty ? 1 : 0)} filter${_selectedFilterCount + (_searchController.text.isNotEmpty ? 1 : 0) == 1 ? '' : 's'} active',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        TextButton(
                          onPressed: _clearAllFilters,
                          child: Text(
                            'Clear all',
                            style: TextStyle(
                              color: kErrorColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _searchController.text.isNotEmpty ||
                                    _selectedFilterCount > 0
                                ? 'Search Results'
                                : '${jobProvider.jobs.length} Jobs Posted',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: kTextPrimary,
                            ),
                          ),
                          if (_searchController.text.isNotEmpty ||
                              _selectedFilterCount > 0)
                            Container(
                              margin: EdgeInsets.only(left: 8.w),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_filteredResultCount}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _searchController.text.isNotEmpty ||
                                _selectedFilterCount > 0
                            ? '${_filteredResultCount} job${_filteredResultCount == 1 ? '' : 's'} found'
                            : 'based on your profile details',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: kGrey600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: jobProvider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : jobProvider.errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: kGrey400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error loading jobs',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: kGrey600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    jobProvider.errorMessage!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: kGrey500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      jobProvider.clearError();
                                      jobProvider.fetchJobs();
                                    },
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : _sortedJobs.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 64,
                                        color: kGrey400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No jobs found',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: kGrey600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Try adjusting your search or filters',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: kGrey500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: () => jobProvider.refreshJobs(),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20.w),
                                      child: Column(
                                        children: List.generate(
                                            _sortedJobs.length, (index) {
                                          return buildJobPost(
                                            logoColors: logoColors,
                                            sampleJobs: _sortedJobs,
                                            index: index,
                                            onJobTap: (job) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      JobDetailsScreen(
                                                          initialJob: job),
                                                ),
                                              );
                                            },
                                            showDetailedModal: (detailedJob) {
                                              // This is no longer needed with the new stateful screen
                                            },
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                ),
                ),
                // SizedBox(height: 20.h),
              ],
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChoiceChip(
            label: Text(
              _selectedFilterCount > 0
                  ? 'Filters ( ${_selectedFilterCount})'
                  : 'Filters',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18.sp, // Increased font size
              ),
            ),
            labelPadding: EdgeInsets.symmetric(
                horizontal: 8.w, vertical: 4.h), // Increased padding
            selected: _selectedFilterCount > 0,
            onSelected: (_) => _showFilterOptions(),
            avatar: Icon(
              _selectedFilterCount > 0
                  ? Icons.filter_list
                  : Icons.filter_list_outlined,
              color: Colors.white,
              size: 28, // Increased icon size
            ),
            backgroundColor:
                _selectedFilterCount > 0 ? kPrimaryColor : kGrey600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                bottomLeft: Radius.circular(24.r),
              ),
              side: const BorderSide(color: Colors.white),
            ),
          ),
          ChoiceChip(
            label: Text(
              _sortBy == 'date' ? 'Date' : 'Relevance',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18.sp, // Increased font size
              ),
            ),
            labelPadding: EdgeInsets.symmetric(
                horizontal: 8.w, vertical: 4.h), // Increased padding
            selected: false,
            onSelected: (_) => _showSortOptions(),
            avatar: Icon(Icons.sort,
                color: Colors.white, size: 28), // Increased icon size
            backgroundColor: kPrimaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(24.r),
                bottomRight: Radius.circular(24.r),
              ),
              side: const BorderSide(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _bulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(fontSize: 18, height: 1.3)),
                    Expanded(
                        child: Text(item,
                            style: const TextStyle(fontSize: 15, height: 1.3))),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class buildJobPost extends StatelessWidget {
  const buildJobPost({
    super.key,
    required List<Color> logoColors,
    required List<JobModel> sampleJobs,
    required this.index,
    required this.onJobTap,
    required this.showDetailedModal,
  })  : logoColors = logoColors,
        sampleJobs = sampleJobs;

  final Function(JobModel) onJobTap;
  final Function(JobModel) showDetailedModal;

  final int index;
  final List<Color> logoColors;
  final List<JobModel> sampleJobs;

  @override
  Widget build(BuildContext context) {
    final job = sampleJobs[index];
    return GestureDetector(
        onTap: () {
          // Show job details screen
          onJobTap(job);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5.w),
          child: Container(
            width: MediaQuery.of(context).size.width - 40.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.grey.shade100,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: logoColors[index % logoColors.length],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: job.companyLogo != null
                            ? Image.network(
                                job.companyLogo!,
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Text(
                                  job.companyName.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(width: 13.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Row(
                              children: [
                                Text(
                                  job.companyName,
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.pin_drop_outlined,
                                  size: 23.r,
                                  color: Colors.grey.shade800,
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  job.companyLocation ?? job.jobLocation,
                                  overflow: TextOverflow.visible,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Replace static bookmark icon with save/unsave logic
                      Consumer2<JobProvider, UserProvider>(
                        builder: (context, jobProvider, userProvider, _) {
                          final user = userProvider.user;
                          final isSaved = jobProvider.isJobSaved(job.id);
                          return IconButton(
                            icon: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              size: 24.r,
                              color: isSaved ? kPrimaryColor : Colors.grey,
                            ),
                            tooltip: isSaved ? 'Unsave Job' : 'Save Job',
                            onPressed: user == null
                                ? null
                                : () async {
                                    if (isSaved) {
                                      await jobProvider.unsaveJob(
                                          user.id, job.id);
                                      // ScaffoldMessenger.of(context)
                                      //     .showSnackBar(
                                      //   SnackBar(
                                      //     content:
                                      //         Text('Job removed from saved'),
                                      //     backgroundColor: Colors.red,
                                      //   ),
                                      // );
                                    } else {
                                      await jobProvider.saveJob(
                                          user.id, job.id);
                                      // ScaffoldMessenger.of(context)
                                      //     .showSnackBar(
                                      //   SnackBar(
                                      //     content: Text('Job saved'),
                                      //     backgroundColor: kPrimaryColor,
                                      //   ),
                                      // );
                                    }
                                  },
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Padding(
                    padding: EdgeInsets.only(left: 60.w),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 23.r,
                          color: Colors.grey.shade800,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          timeago.format(
                            DateTime.parse(job.postedDate),
                          ),
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(height: 12.h),
                  // Second tag row: First 3 tags from job tags
                  // if (job.tags.isNotEmpty)
                  // Padding(
                  //   padding: EdgeInsets.only(left: 60.w),
                  //   child: Row(
                  //     children: job.tags.take(3).map((tag) {
                  //       return Container(
                  //         margin: EdgeInsets.only(right: 6.w),
                  //         padding: EdgeInsets.symmetric(
                  //             horizontal: 8.w, vertical: 2.h),
                  //         decoration: BoxDecoration(
                  //           color: Colors.grey.withOpacity(0.12),
                  //           borderRadius: BorderRadius.circular(6),
                  //         ),
                  //         child: Text(
                  //           tag,
                  //           style: TextStyle(
                  //             color: Colors.grey.shade700,
                  //             fontSize: 12.sp,
                  //             fontWeight: FontWeight.w500,
                  //           ),
                  //         ),
                  //       );
                  //     }).toList(),
                  //   ),
                  // ),
                  // SizedBox(height: 8.h),
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton(
                  //     onPressed: () {},
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: const Color(0xFF2563EB),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //       padding: EdgeInsets.symmetric(vertical: 12.h),
                  //     ),
                  //     child: const Text('Apply',
                  //         style: TextStyle(
                  //             color: Colors.white, fontWeight: FontWeight.bold)),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ));
  }
}

// Add the logoColors list here since we removed the sample_data.dart import
final List<Color> logoColors = [
  Color(0xFF4F8EF7), // Blue
  Color(0xFFF76F4F), // Orange
  Color(0xFF4FF7A1), // Green
  Color(0xFFF7E14F), // Yellow
  Color(0xFFB44FF7), // Purple
  Color(0xFFF74F8E), // Pink
  Color(0xFF4FF0F7), // Cyan
  Color(0xFF7DF74F), // Lime
  Color(0xFFF79C4F), // Amber
  Color(0xFF4F5AF7), // Indigo
];

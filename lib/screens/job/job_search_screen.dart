import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/screens/job/apply_screen.dart';
import 'package:home_service_app/screens/job/sample_data.dart';
import 'package:home_service_app/screens/job/core/constants/color.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:home_service_app/models/job_model.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String? _mapIndustryToCategory(String industry) {
    // Map onboarding industries to job categories
    switch (industry.toLowerCase()) {
      case 'it':
        return 'IT';
      case 'healthcare':
        return 'Healthcare';
      case 'education':
        return 'Education';
      case 'finance':
        return 'Finance';
      case 'retail':
        return 'Retail';
      default:
        return industry;
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
    return sampleJobs.where((job) {
      // Search filter
      final searchQuery = _searchController.text.toLowerCase().trim();
      if (searchQuery.isNotEmpty) {
        final matchesSearch = job.title.toLowerCase().contains(searchQuery) ||
            job.companyName.toLowerCase().contains(searchQuery) ||
            job.category.toLowerCase().contains(searchQuery) ||
            job.jobLocation.toLowerCase().contains(searchQuery);
        if (!matchesSearch) return false;
      }

      // Job type filter
      if (_selectedJobType != null && job.jobType != _selectedJobType)
        return false;

      // Location filter
      if (_selectedLocation != null && job.jobLocation != _selectedLocation)
        return false;

      // Category filter
      if (_selectedCategory != null && job.category != _selectedCategory)
        return false;

      // Date posted filter
      if (_selectedDatePosted != null) {
        final now = DateTime.now();
        final posted = DateTime.tryParse(job.postedDate);
        if (posted == null) return false;
        if (_selectedDatePosted == 'Last 24 hours' &&
            now.difference(posted).inHours > 24) return false;
        if (_selectedDatePosted == 'Last 7 days' &&
            now.difference(posted).inDays > 7) return false;
        if (_selectedDatePosted == 'Last 30 days' &&
            now.difference(posted).inDays > 30) return false;
      }
      return true;
    }).toList();
  }

  List<JobModel> get _sortedJobs {
    final filtered = _filteredJobs;

    // Always sort by relevance if user has preferences
    if (_userJobTypes.isNotEmpty ||
        _userJobRole != null ||
        _userIndustries.isNotEmpty) {
      filtered.sort((a, b) {
        int scoreA = _calculateRelevanceScore(a);
        int scoreB = _calculateRelevanceScore(b);
        return scoreB.compareTo(scoreA); // Higher score first
      });
    } else {
      // Default sorting for users without preferences
      if (_sortBy == 'date') {
        filtered.sort((a, b) {
          final dateA = DateTime.tryParse(a.postedDate) ?? DateTime.now();
          final dateB = DateTime.tryParse(b.postedDate) ?? DateTime.now();
          return dateB.compareTo(dateA); // Newest first
        });
      }
    }
    return filtered;
  }

  int _calculateRelevanceScore(JobModel job) {
    int score = 0;

    // Job type match (highest priority)
    if (_userJobTypes.contains(job.jobType)) {
      score += 100;
    }

    // Job role match in title
    if (_userJobRole != null && _userJobRole!.isNotEmpty) {
      final role = _userJobRole!.toLowerCase();
      if (job.title.toLowerCase().contains(role)) {
        score += 80;
      }
      if (job.description.toLowerCase().contains(role)) {
        score += 40;
      }
    }

    // Industry/category match
    if (_userIndustries.isNotEmpty) {
      for (String industry in _userIndustries) {
        final category = _mapIndustryToCategory(industry);
        if (job.category.toLowerCase() == category?.toLowerCase()) {
          score += 60;
          break;
        }
      }
    }

    // Recent posts get bonus points
    final posted = DateTime.tryParse(job.postedDate);
    if (posted != null) {
      final daysSincePosted = DateTime.now().difference(posted).inDays;
      if (daysSincePosted <= 7)
        score += 20;
      else if (daysSincePosted <= 30) score += 10;
    }

    return score;
  }

  int get _filteredResultCount => _filteredJobs.length;

  String _sortBy = 'relevance';

  @override
  void dispose() {
    _searchController.dispose();
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
            setState(() {
              // Trigger search
            });
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
                                  children: [
                                    RadioListTile<String>(
                                      activeColor: kPrimaryColor,
                                      title: const Text('Full-time'),
                                      value: 'Full-time',
                                      groupValue: _selectedJobType,
                                      onChanged: (value) {
                                        setModalState(
                                            () => _selectedJobType = value);
                                        setState(() {});
                                      },
                                    ),
                                    RadioListTile<String>(
                                      activeColor: kPrimaryColor,
                                      title: const Text('Part-time'),
                                      value: 'Part-time',
                                      groupValue: _selectedJobType,
                                      onChanged: (value) {
                                        setModalState(
                                            () => _selectedJobType = value);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                                ExpansionTile(
                                  title: const Text('Location'),
                                  children: [
                                    RadioListTile<String>(
                                      activeColor: kPrimaryColor,
                                      title: const Text('Remote'),
                                      value: 'Remote',
                                      groupValue: _selectedLocation,
                                      onChanged: (value) {
                                        setModalState(
                                            () => _selectedLocation = value);
                                        setState(() {});
                                      },
                                    ),
                                    RadioListTile<String>(
                                      activeColor: kPrimaryColor,
                                      title: const Text('Hybrid'),
                                      value: 'Hybrid',
                                      groupValue: _selectedLocation,
                                      onChanged: (value) {
                                        setModalState(
                                            () => _selectedLocation = value);
                                        setState(() {});
                                      },
                                    ),
                                    RadioListTile<String>(
                                      activeColor: kPrimaryColor,
                                      title: const Text('On-site'),
                                      value: 'On-site',
                                      groupValue: _selectedLocation,
                                      onChanged: (value) {
                                        setModalState(
                                            () => _selectedLocation = value);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                                ExpansionTile(
                                  title: const Text('Category'),
                                  children: sampleJobs
                                      .map((job) => job.category)
                                      .toSet()
                                      .map((cat) => RadioListTile<String>(
                                            activeColor: kPrimaryColor,
                                            title: Text(cat),
                                            value: cat,
                                            groupValue: _selectedCategory,
                                            onChanged: (value) {
                                              setModalState(() =>
                                                  _selectedCategory = value);
                                              setState(() {});
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
                          child: SaveButton(
                            text:
                                'Apply Filter (${_filteredResultCount} results)',
                            onPressed: () {
                              setState(() {
                                // Trigger rebuild with new filters
                              });
                              Navigator.pop(context);
                            },
                            height: 48,
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
      appBar: AppBar(
        backgroundColor: kCardColorLight,
        elevation: 0,
        title: Text('Find your dream job',
            style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: kTextPrimary),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w).copyWith(top: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50.h,
                        child: TextField(
                          controller: _searchController,
                          autofocus:
                              false, // Don't focus initially for any user
                          onChanged: (value) {
                            setState(() {
                              // Trigger rebuild when search text changes
                            });
                          },
                          decoration: InputDecoration(
                            hintText:
                                _isListening ? 'Listening...' : 'Search For...',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: _isListening ? kPrimaryColor : kGrey600,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              size: 24.r,
                              color: _isListening ? kPrimaryColor : null,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, size: 24.r),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : IconButton(
                                    icon: Icon(
                                      _isListening
                                          ? Icons.mic
                                          : Icons.keyboard_voice_outlined,
                                      size: 24.r,
                                      color:
                                          _isListening ? kPrimaryColor : null,
                                    ),
                                    onPressed: _startListening,
                                  ),
                            filled: true,
                            fillColor: _isListening
                                ? kPrimaryColor.withOpacity(0.1)
                                : kGrey100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: _isListening
                                    ? kPrimaryColor
                                    : Colors.transparent,
                                width: _isListening ? 2 : 0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Voice search help button
                if (!_speechEnabled)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 8.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: kWarningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kWarningColor.withOpacity(0.3)),
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
                    margin: EdgeInsets.only(top: 8.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
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
                padding: EdgeInsets.only(bottom: 8.h),
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
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _searchController.text.isNotEmpty ||
                                _selectedFilterCount > 0
                            ? 'Search Results'
                            : 'Job matches with you',
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
              child: _sortedJobs.isEmpty
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
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: List.generate(_sortedJobs.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              _showJobDetailsModal(context, _sortedJobs[index],
                                  parentContext: context);
                            },
                            child: buildJobPost(
                                logoColors: logoColors,
                                sampleJobs: _sortedJobs,
                                index: index),
                          );
                        }),
                      ),
                    ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChoiceChip(
            label: Text(
              _selectedFilterCount > 0
                  ? 'Filters (${_selectedFilterCount})'
                  : 'Filters',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            selected: _selectedFilterCount > 0,
            onSelected: (_) => _showFilterOptions(),
            avatar: Icon(
              _selectedFilterCount > 0
                  ? Icons.filter_list
                  : Icons.filter_list_outlined,
              color: Colors.white,
              size: 20,
            ),
            backgroundColor:
                _selectedFilterCount > 0 ? kPrimaryColor : kGrey600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                bottomLeft: Radius.circular(20.r),
              ),
              side: const BorderSide(color: Colors.white),
            ),
          ),
          ChoiceChip(
            label: Text(
              _sortBy == 'date' ? 'Date' : 'Relevance',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            selected: false,
            onSelected: (_) => _showSortOptions(),
            avatar: const Icon(Icons.sort, color: Colors.white, size: 20),
            backgroundColor: kPrimaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
              side: const BorderSide(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showJobDetailsModal(BuildContext context, JobModel job,
      {required BuildContext parentContext}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: job.companyLogo != null
                              ? Image.network(job.companyLogo!,
                                  fit: BoxFit.cover)
                              : Center(
                                  child: Text(
                                    job.companyName
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    job.companyName,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 15),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.location_on,
                                      size: 16, color: Colors.grey),
                                  Text(
                                    job.companyLocation,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 15),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _pillChip('Full Time', kPrimaryColor),
                        const SizedBox(width: 8),
                        _pillChip('Remote', Colors.blue),
                        const SizedBox(width: 8),
                        _pillChip(job.salary, Colors.black),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text('About the Role',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(
                      job.description ??
                          'As a Senior UI/UX Designer at Netflix, you’ll be a champion for user experience, translating user needs into intuitive and visually appealing features. You’ll leverage your creativity, design expertise, and technical knowledge to craft exceptional experiences across various digital products.',
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                    const SizedBox(height: 18),
                    const Text('Qualification',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    _bulletList([
                      'Minimum 5+ years of experience as a UI/UX Designer or similar role.',
                      'Strong portfolio showcasing a variety of UI/UX projects.',
                      'Proven ability to conduct user research and translate insights into actionable design.',
                      'Mastery of design tools like Figma, Sketch, InVision, and prototyping tools.',
                      'Excellent communication and collaboration skills.',
                      'Ability to work independently and manage multiple projects simultaneously.',
                      'A keen eye for detail and a passion for creating user-centered experiences.',
                    ]),
                    const SizedBox(height: 28),
                    SaveButton(
                      text: 'Apply for this Job',
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          parentContext,
                          MaterialPageRoute(
                            builder: (context) => const ApplyScreen(),
                          ),
                        );
                      },
                      height: 50,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
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
  })  : logoColors = logoColors,
        sampleJobs = sampleJobs;

  final int index;
  final List<Color> logoColors;
  final List<JobModel> sampleJobs;

  @override
  Widget build(BuildContext context) {
    final job = sampleJobs[index];
    // Mock tags for demo
    final List<String> tags = [
      if (job.jobLocation == 'Remote') 'Remote',
      if (job.jobLocation == 'Hybrid') 'Hybrid',
      if (job.jobLocation == 'On-site') 'On-site',
      if (job.jobType == 'Full-time') 'Full-time',
      if (job.jobType == 'Contract') 'Contract',
    ];
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.w),
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
          padding: EdgeInsets.all(16.w),
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
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: TextStyle(
                            fontSize: 17.sp,
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
                                fontSize: 14.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              '• ${job.companyLocation}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: tags.map((tag) {
                            Color tagColor;
                            if (tag == 'Remote')
                              tagColor = Colors.blue;
                            else if (tag == 'Hybrid')
                              tagColor = Colors.purple;
                            else if (tag == 'On-site')
                              tagColor = Colors.green;
                            else if (tag == 'Full-time')
                              tagColor = Colors.blue.shade700;
                            else
                              tagColor = Colors.orange;
                            return Container(
                              margin: EdgeInsets.only(right: 6.w),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: tagColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: tagColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.bookmark_border,
                    size: 24.r,
                    color: Colors.grey,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.only(left: 60.w),
                child: Row(
                  children: [
                    Text(
                      '${job.salary} / Month',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      timeago.format(
                        DateTime.parse(job.postedDate),
                      ),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
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
    );
  }
}

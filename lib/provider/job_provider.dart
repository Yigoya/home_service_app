import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:home_service_app/models/job_model.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:logger/logger.dart';

class JobProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  List<JobModel> _jobs = [];
  List<JobModel> _filteredJobs = [];
  String _sortBy = 'Newest';

  // Saved jobs state
  final Set<int> _savedJobIds = {};
  List<JobModel> _savedJobs = [];
  bool _isLoadingSavedJobs = false;
  String? _savedJobsError;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<JobModel> get jobs => _jobs;
  List<JobModel> get filteredJobs => _filteredJobs;
  String get sortBy => _sortBy;

  List<JobModel> get savedJobs => _savedJobs;
  bool get isLoadingSavedJobs => _isLoadingSavedJobs;
  String? get savedJobsError => _savedJobsError;

  bool isJobSaved(int jobId) => _savedJobIds.contains(jobId);

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set sort by
  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  // Fetch jobs from API
  Future<void> fetchJobs({String? sortBy}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{};
      if (sortBy != null) {
        queryParams['Sortedby'] = sortBy;
      } else {
        queryParams['Sortedby'] = _sortBy;
      }

      final response = await _apiService.getRequestByQueryWithoutToken(
        '/jobs',
        queryParams,
      );

      // Debug logging to understand response structure
      Logger().d('API Response Status: ${response.statusCode}');
      Logger().d('API Response Data Type: ${response.data.runtimeType}');
      Logger().d('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        // Handle different possible response structures
        List<dynamic> jobsData;

        if (response.data is Map<String, dynamic>) {
          // If response.data is a map, look for 'content', 'data', or 'jobs' key
          final data = response.data as Map<String, dynamic>;
          jobsData = data['content'] ?? data['data'] ?? data['jobs'] ?? [];
        } else if (response.data is List) {
          // If response.data is directly a list
          jobsData = response.data as List<dynamic>;
        } else {
          // Fallback to empty list
          jobsData = [];
        }

        // Ensure jobsData is a list (this check is redundant but kept for clarity)
        if (jobsData.isEmpty && response.data is Map<String, dynamic>) {
          Logger().w('No jobs found in response');
        }

        _jobs = jobsData.map((jobData) => JobModel.fromMap(jobData)).toList();
        _filteredJobs = List.from(_jobs);
        Logger().d('Fetched ${_jobs.length} jobs successfully');
      } else {
        _errorMessage = 'Failed to fetch jobs';
        Logger().e('Failed to fetch jobs: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Failed to fetch jobs';
      Logger().e('DioException while fetching jobs: $e');
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      Logger().e('Unexpected error while fetching jobs: $e');
    } finally {
      _isLoading = false;
      // Only notify if we're still in a valid state
      try {
        notifyListeners();
      } catch (e) {
        Logger().w('Failed to notify listeners: $e');
      }
    }
  }

  // Filter jobs based on search criteria
  void filterJobs({
    String? searchQuery,
    String? jobType,
    String? location,
    String? category,
    String? datePosted,
  }) {
    _filteredJobs = _jobs.where((job) {
      // Search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase().trim();
        final matchesSearch = job.title.toLowerCase().contains(query) ||
            job.companyName.toLowerCase().contains(query) ||
            job.category.toLowerCase().contains(query) ||
            job.jobLocation.toLowerCase().contains(query) ||
            job.description.toLowerCase().contains(query);
        if (!matchesSearch) return false;
      }

      // Job type filter
      if (jobType != null && job.jobType != jobType) return false;

      // Location filter
      if (location != null && job.jobLocation != location) return false;

      // Category filter
      if (category != null && job.category != category) return false;

      // Date posted filter
      if (datePosted != null) {
        final now = DateTime.now();
        final posted = DateTime.tryParse(job.postedDate);
        if (posted == null) return false;

        switch (datePosted) {
          case 'Last 24 hours':
            if (now.difference(posted).inHours > 24) return false;
            break;
          case 'Last 7 days':
            if (now.difference(posted).inDays > 7) return false;
            break;
          case 'Last 30 days':
            if (now.difference(posted).inDays > 30) return false;
            break;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // Sort jobs by relevance based on user preferences
  void sortJobsByRelevance({
    List<String>? userJobTypes,
    String? userJobRole,
    List<String>? userIndustries,
  }) {
    if (userJobTypes == null && userJobRole == null && userIndustries == null) {
      return;
    }

    _filteredJobs.sort((a, b) {
      int scoreA = _calculateRelevanceScore(
          a, userJobTypes, userJobRole, userIndustries);
      int scoreB = _calculateRelevanceScore(
          b, userJobTypes, userJobRole, userIndustries);
      return scoreB.compareTo(scoreA); // Higher score first
    });

    notifyListeners();
  }

  int _calculateRelevanceScore(
    JobModel job,
    List<String>? userJobTypes,
    String? userJobRole,
    List<String>? userIndustries,
  ) {
    int score = 0;

    // Job type match (highest priority)
    if (userJobTypes != null && userJobTypes.contains(job.jobType)) {
      score += 100;
    }

    // Job role match in title
    if (userJobRole != null && userJobRole.isNotEmpty) {
      final role = userJobRole.toLowerCase();
      if (job.title.toLowerCase().contains(role)) {
        score += 80;
      }
      if (job.description.toLowerCase().contains(role)) {
        score += 40;
      }
    }

    // Industry/category match
    if (userIndustries != null && userIndustries.isNotEmpty) {
      for (String industry in userIndustries) {
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
      if (daysSincePosted <= 7) {
        score += 20;
      } else if (daysSincePosted <= 30) {
        score += 10;
      }
    }

    return score;
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

  // Clear all filters
  void clearFilters() {
    _filteredJobs = List.from(_jobs);
    notifyListeners();
  }

  // Get unique categories from jobs
  List<String> get uniqueCategories {
    return _jobs.map((job) => job.category).toSet().toList();
  }

  // Get unique job types from jobs
  List<String> get uniqueJobTypes {
    return _jobs.map((job) => job.jobType).toSet().toList();
  }

  // Get unique locations from jobs
  List<String> get uniqueLocations {
    return _jobs.map((job) => job.jobLocation).toSet().toList();
  }

  // Get job by ID
  JobModel? getJobById(int id) {
    try {
      return _jobs.firstWhere((job) => job.id == id);
    } catch (e) {
      return null;
    }
  }

  // Refresh jobs
  Future<void> refreshJobs() async {
    await fetchJobs();
  }

  // Fetch job details by ID
  Future<JobModel?> fetchJobDetails(int jobId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getRequestByQueryWithoutToken(
        '/jobs/$jobId',
        {},
      );

      Logger().d('Job Details API Response Status: ${response.statusCode}');
      Logger().d('Job Details API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final jobData = response.data;
        final job = JobModel.fromMap(jobData);
        Logger().d('Fetched job details successfully for ID: $jobId');
        return job;
      } else {
        _errorMessage = 'Failed to fetch job details';
        Logger().e('Failed to fetch job details: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      _errorMessage =
          e.response?.data['message'] ?? 'Failed to fetch job details';
      Logger().e('DioException while fetching job details: $e');
      return null;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      Logger().e('Unexpected error while fetching job details: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSavedJobs(int userId) async {
    _isLoadingSavedJobs = true;
    _savedJobsError = null;
    notifyListeners();
    try {
      final response = await _apiService.getSavedJobs(userId);
      if (response.statusCode == 200) {
        final List<dynamic> jobsData = response.data is List
            ? response.data
            : response.data['jobs'] ?? response.data['data'] ?? [];
        _savedJobs = jobsData.map((job) => JobModel.fromMap(job)).toList();
        _savedJobIds.clear();
        _savedJobIds.addAll(_savedJobs.map((job) => job.id));
      } else {
        _savedJobsError = 'Failed to fetch saved jobs';
      }
    } catch (e) {
      _savedJobsError = 'Error fetching saved jobs: $e';
    } finally {
      _isLoadingSavedJobs = false;
      notifyListeners();
    }
  }

  Future<void> saveJob(int userId, int jobId) async {
    try {
      final response = await _apiService.saveJob(userId: userId, jobId: jobId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _savedJobIds.add(jobId);
        notifyListeners();
      }
    } catch (e) {
      // Optionally handle error
    }
  }

  Future<void> unsaveJob(int userId, int jobId) async {
    try {
      final response =
          await _apiService.removeSavedJob(userId: userId, jobId: jobId);
      if (response.statusCode == 200 || response.statusCode == 204) {
        _savedJobIds.remove(jobId);
        // Remove the job from the saved jobs list
        _savedJobs.removeWhere((job) => job.id == jobId);
        notifyListeners();
      }
    } catch (e) {
      // Optionally handle error
    }
  }

  // Clear saved jobs when user logs out
  void clearSavedJobs() {
    _savedJobs.clear();
    _savedJobIds.clear();
    _isLoadingSavedJobs = false;
    _savedJobsError = null;
    notifyListeners();
  }
}

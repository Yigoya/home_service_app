import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/screens/job/auth/job_finder_login.dart';
import 'package:home_service_app/screens/job/core/constants/color.dart';
import 'package:home_service_app/models/job_model.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:home_service_app/screens/job/auth/return_destination.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ApplicationModel> _applications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;

      if (user == null) {
        setState(() {
          _errorMessage = 'User not found. Please login again.';
          _isLoading = false;
        });
        return;
      }

      Logger().d('Loading applications for user ID: ${user.id}');
      final response = await ApiService().getUserApplications(user.id);

      if (response.statusCode == 200) {
        final List<dynamic> applicationsData = response.data is List
            ? response.data
            : response.data['applications'] ?? response.data['data'] ?? [];

        final applications = applicationsData
            .map((app) => ApplicationModel.fromMap(app))
            .toList();

        setState(() {
          _applications = applications;
          _isLoading = false;
        });

        Logger().d('Loaded ${applications.length} applications');
      } else {
        setState(() {
          _errorMessage =
              'Failed to load applications (Status: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger().e('Error loading applications: $e');
      String errorMessage = 'Error loading applications';

      if (e.toString().contains('500')) {
        errorMessage =
            'Server error. Please try again later or contact support if the problem persists.';
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        errorMessage = 'Authentication error. Please login again.';
      } else if (e.toString().contains('404')) {
        errorMessage = 'No applications found for this user.';
      }

      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'In Review':
        return kWarningColor;
      case 'Shortlisted':
        return kSuccessColor;
      case 'Rejected':
        return kErrorColor;
      case 'Hired':
        return kPrimaryColor;
      default:
        return kGrey500;
    }
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _statusColor(status),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _applicationCard(Map<String, dynamic> app) {
    // Map the real API response to the format expected by the original UI
    final title = app['jobTitle'] ?? 'Unknown Job';
    final company = app['companyName'] ?? 'Unknown Company';
    final status = app['status'] ?? 'Pending';
    final jobType = app['jobType'] ?? '';
    final salaryRange = app['salaryRange'] ?? '';
    final appliedDate = app['appliedDate'] != null
        ? timeago.format(DateTime.parse(app['appliedDate']))
        : app['applicationDate'] != null
            ? timeago.format(DateTime.parse(app['applicationDate']))
            : 'Unknown';
    final responseDate = 'Pending'; // API doesn't provide response date yet

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCardColorLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kGrey300.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: kGrey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
              _statusBadge(status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            company,
            style: TextStyle(color: kGrey600, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Text('Applied: $appliedDate', style: const TextStyle(fontSize: 13)),
          if (status == 'Hired')
            Text('Offer Received: $responseDate',
                style: const TextStyle(fontSize: 13))
          else if (status == 'Rejected')
            Text('Status Updated: $responseDate',
                style: const TextStyle(fontSize: 13))
          else
            Text('Expected Response: $responseDate',
                style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: kPrimaryColor,
                side: BorderSide(color: kPrimaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ApplicationDetailsScreen(application: app),
                  ),
                );
              },
              child: const Text('View Application'),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filteredApps(String status) {
    if (status == 'All')
      return _applications.map((app) => app.toMap()).toList();

    // Map UI status to API status
    String apiStatus;
    switch (status) {
      case 'In Review':
        apiStatus = 'submitted';
        break;
      case 'Shortlisted':
        apiStatus = 'shortlisted';
        break;
      case 'Hired':
        apiStatus = 'hired';
        break;
      case 'Rejected':
        apiStatus = 'rejected';
        break;
      default:
        apiStatus = status.toLowerCase();
    }

    return _applications
        .where((app) => app.status.toLowerCase() == apiStatus)
        .map((app) => app.toMap())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kCardColorLight,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Applications',
            style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: kTextPrimary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: kCardColorLight,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: kPrimaryColor,
              labelColor: kTextPrimary,
              unselectedLabelColor: kGrey600,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'In Review'),
                Tab(text: 'Shortlisted'),
                Tab(text: 'Hired'),
                Tab(text: 'Rejected'),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final user = userProvider.user;

          // Check if user is logged in
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 64,
                    color: kGrey400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Login to view applications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to access your job applications',
                    style: TextStyle(
                      fontSize: 16,
                      color: kGrey600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // User is not logged in, navigate to job finder login
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobFinderLoginPage(
                            returnDestination: ReturnDestination.applications,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // User is logged in, show applications
          return _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: kPrimaryColor),
                      const SizedBox(height: 16),
                      Text('Loading applications...',
                          style: TextStyle(color: kTextPrimary)),
                    ],
                  ),
                )
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(_errorMessage!,
                              style: TextStyle(color: kTextPrimary),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadApplications,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _applications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.work_outline,
                                  size: 64, color: kGrey600),
                              const SizedBox(height: 16),
                              Text('No applications yet',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: kTextPrimary)),
                              const SizedBox(height: 8),
                              Text('Start applying for jobs to see them here',
                                  style: TextStyle(color: kGrey600)),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              ...[
                                'All',
                                'In Review',
                                'Shortlisted',
                                'Hired',
                                'Rejected'
                              ].map((status) {
                                final apps = _filteredApps(status);
                                return RefreshIndicator(
                                  onRefresh: _loadApplications,
                                  child: ListView.builder(
                                    itemCount: apps.length,
                                    itemBuilder: (context, idx) =>
                                        _applicationCard(apps[idx]),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        );
        },
      ),
    );
  }
}

class ApplicationDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> application;

  const ApplicationDetailsScreen({super.key, required this.application});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'shortlisted':
        return Colors.blue;
      case 'hired':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 'In Review';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'shortlisted':
        return 'Shortlisted';
      case 'hired':
        return 'Hired';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kCardColorLight,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: Text('Application Details',
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
                      Text(application['jobTitle'] ?? 'Unknown Job',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22)),
                      const SizedBox(height: 2),
                      Text(application['companyName'] ?? 'Unknown Company',
                          style: TextStyle(color: kGrey600, fontSize: 16)),
                      const SizedBox(height: 14),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Application Status
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(application['status'] ?? 'submitted')
                              .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                        _getStatusDisplay(application['status'] ?? 'submitted'),
                        style: TextStyle(
                            color: _getStatusColor(
                                application['status'] ?? 'submitted'),
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),
                  Text('Applied: ${application['appliedDate'] ?? 'Unknown'}',
                      style: TextStyle(color: kGrey600)),
                ],
              ),
              const SizedBox(height: 18),
              // Job Summary
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.work_outline, size: 18, color: kGrey600),
                        const SizedBox(width: 8),
                        Text(application['jobType'] ?? 'Not specified',
                            style: TextStyle(fontSize: 15)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 18, color: kGrey600),
                        const SizedBox(width: 8),
                        Text(
                            application['location'] ?? 'Location not specified',
                            style: TextStyle(fontSize: 15)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 18, color: kGrey600),
                        const SizedBox(width: 8),
                        Text(
                            application['salaryRange'] ??
                                'Salary not specified',
                            style: TextStyle(fontSize: 15)),
                      ],
                    ),
                  ],
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              application['resumeUrl'] != null
                                  ? 'Resume.pdf'
                                  : 'No resume uploaded',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text(
                              application['resumeUrl'] != null
                                  ? 'Resume available'
                                  : 'No resume uploaded',
                              style: TextStyle(color: kGrey600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Cover Letter
              const Text('Cover Letter',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: kCardColorLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kGrey300),
                ),
                padding: const EdgeInsets.all(16),
                child: Text(
                  application['coverLetter'] ?? 'No cover letter provided',
                  style: TextStyle(fontSize: 15, color: kTextPrimary),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

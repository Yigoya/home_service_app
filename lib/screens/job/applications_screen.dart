import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/screens/job/core/constants/color.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> applications = [
    {
      'title': 'Senior Product Designer',
      'company': 'Tech Innovators Inc.',
      'status': 'In Review',
      'applied': 'Oct 12, 2023',
      'response': 'Oct 20, 2023',
    },
    {
      'title': 'UX/UI Designer',
      'company': 'Creative Solutions Co.',
      'status': 'Shortlisted',
      'applied': 'Oct 10, 2023',
      'response': 'Oct 18, 2023',
    },
    {
      'title': 'Frontend Developer',
      'company': 'Digital Frontier Ltd.',
      'status': 'Rejected',
      'applied': 'Oct 08, 2023',
      'response': 'Oct 15, 2023',
    },
    {
      'title': 'Data Analyst',
      'company': 'Data Corp.',
      'status': 'Hired',
      'applied': 'Oct 05, 2023',
      'response': 'Oct 14, 2023',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
                  app['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
              _statusBadge(app['status']),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            app['company'],
            style: TextStyle(color: kGrey600, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Text('Applied: ${app['applied']}',
              style: const TextStyle(fontSize: 13)),
          if (app['status'] == 'Hired')
            Text('Offer Received: ${app['response']}',
                style: const TextStyle(fontSize: 13))
          else if (app['status'] == 'Rejected')
            Text('Status Updated: ${app['response']}',
                style: const TextStyle(fontSize: 13))
          else
            Text('Expected Response: ${app['response']}',
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
                    builder: (context) => const ApplicationDetailsScreen(),
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
    if (status == 'All') return applications;
    return applications.where((a) => a['status'] == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kCardColorLight,
        elevation: 0,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: TabBarView(
          controller: _tabController,
          children: [
            ...['All', 'In Review', 'Shortlisted', 'Hired', 'Rejected']
                .map((status) {
              final apps = _filteredApps(status);
              return ListView.builder(
                itemCount: apps.length,
                itemBuilder: (context, idx) => _applicationCard(apps[idx]),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class ApplicationDetailsScreen extends StatelessWidget {
  const ApplicationDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kCardColorLight,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
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
              const SizedBox(height: 30),
              // Application Status
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('Shortlisted',
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),
                  Text('Applied: Oct 10, 2023',
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
                        const Text('Full-time', style: TextStyle(fontSize: 15)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 18, color: kGrey600),
                        const SizedBox(width: 8),
                        const Text('Remote', style: TextStyle(fontSize: 15)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 18, color: kGrey600),
                        const SizedBox(width: 8),
                        const Text('100K - \$120K',
                            style: TextStyle(fontSize: 15)),
                      ],
                    ),
                    SizedBox(height: 6),
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
                          const Text('my_resume_final.pdf',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text('Uploaded on 12/04/24',
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
                  'I am excited to apply for this position. My experience in software engineering and my passion for building user-centric products make me a great fit for your team.',
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

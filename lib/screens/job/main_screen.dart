import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/screens/job/applications_screen.dart';
import 'package:home_service_app/screens/job/job_search_screen.dart';
import 'package:home_service_app/screens/job/profile_screen.dart';
import 'package:home_service_app/screens/job/saved_jobs_screen.dart';
import 'package:home_service_app/screens/job/core/constants/color.dart';

class MainScreen extends StatefulWidget {
  final Map<String, dynamic>? onboardingData;
  final int? initialTabIndex;

  const MainScreen({super.key, this.onboardingData, this.initialTabIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      JobSearchScreen(onboardingData: widget.onboardingData),
      const SavedJobsScreen(),
      const ApplicationsScreen(),
      const ProfileScreen(),
    ];

    // Set initial tab index if provided
    if (widget.initialTabIndex != null) {
      _currentIndex = widget.initialTabIndex!;
    }
  }

  final List<_NavItemData> _navItems = const [
    _NavItemData(icon: Icons.work_outline, label: 'Home'),
    _NavItemData(icon: Icons.bookmark, label: 'My Jobs'),
    _NavItemData(icon: Icons.work_outline, label: 'Applications'),
    _NavItemData(icon: Icons.more_vert, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: kCardColorLight,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.only(bottom: 4, top: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            final selected = _currentIndex == index;
            final item = _navItems[index];
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.ease,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? kPrimaryColor.withOpacity(0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        size: 26,
                        color: selected ? kPrimaryColor : kGrey500,
                      ),
                    ),
                    // SizedBox(height: 2.h),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                        color: selected ? kPrimaryColor : kGrey500,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData({required this.icon, required this.label});
}

import 'package:flutter/material.dart';
import 'package:home_service_app/provider/notification_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/home/more_page_technician.dart';
import 'package:home_service_app/screens/notification.dart';
import 'package:home_service_app/screens/profile/technician_about_me.dart';
import 'package:home_service_app/screens/profile/technician_profile_page.dart';
import 'package:home_service_app/screens/profile/technician_schedule.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TechnicianNavigation extends StatefulWidget {
  const TechnicianNavigation({super.key});

  @override
  _TechnicianNavigationState createState() => _TechnicianNavigationState();
}

class _TechnicianNavigationState extends State<TechnicianNavigation> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      const TechnicianProfilePage(),
      const MorePageTechnician()
      // const TechnicianSchedule(),
      // const NotificationsPage(),
      // TechnicianAboutMe(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.construction, size: 24),
        title: ("Services"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey[800],
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.more_horiz, size: 24),
        title: ("More"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey[800],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      onItemSelected: (int) {
        if (int == 2 && user != null) {
          Provider.of<NotificationProvider>(context, listen: false)
              .loadNotifications(user.id);
        }
      },
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset:
          true, // This needs to be true if you want to move up the screen on a non-scrollable screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardAppears: true,
      popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,

      padding: EdgeInsets.symmetric(
        vertical: 8.h,
      ),

      backgroundColor: Colors.white,
      isVisible: true,
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          duration: Duration(milliseconds: 200),
          screenTransitionAnimationType: ScreenTransitionAnimationType.fadeIn,
        ),
      ),
      confineToSafeArea: true,
      navBarHeight: kBottomNavigationBarHeight.h,
      navBarStyle: NavBarStyle.style6,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:home_service_app/provider/notification_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/home/home.dart';
import 'package:home_service_app/screens/home/more_page.dart';
import 'package:home_service_app/screens/marketplace/marketplace_home_page.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/l10n/app_localizations.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      const HomePage(),
      const MorePage(),
      // const DisputeListPage(),
      // const NotificationsPage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.construction, size: 24),
        title: AppLocalizations.of(context)!.services,
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey[800],
      ),

      PersistentBottomNavBarItem(
        icon: const Icon(Icons.more_horiz, size: 24),
        title: AppLocalizations.of(context)!.seeMore,
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
          Provider.of<UserProvider>(context, listen: false).fetchDispute();
        }
        if (int == 3 && user != null) {
          Provider.of<NotificationProvider>(context, listen: false)
              .loadNotifications(user.id);
        }
      },
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
      padding: EdgeInsets.symmetric(
        vertical: 8.h,
      ),
      backgroundColor: Colors.white,
      isVisible: true,
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
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

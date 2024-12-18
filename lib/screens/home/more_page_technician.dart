import 'package:flutter/material.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/account_setting.dart';
import 'package:home_service_app/screens/booking/buy_coins_page.dart';
import 'package:home_service_app/screens/contact_page.dart';
import 'package:home_service_app/screens/disputelist_page.dart';
import 'package:home_service_app/screens/home/coming_soon.dart';
import 'package:home_service_app/screens/language_selector_page.dart';
import 'package:home_service_app/screens/notification.dart';
import 'package:home_service_app/screens/profile/customer_profile_page.dart';
import 'package:home_service_app/screens/profile/technician_about_me.dart';
import 'package:home_service_app/screens/saved_address.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/utils/functions.dart';
import 'package:home_service_app/utils/route_generator.dart';
import 'package:home_service_app/widgets/customlist_tile.dart';
import 'package:home_service_app/widgets/language_selector.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MorePageTechnician extends StatelessWidget {
  const MorePageTechnician({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final coin = Provider.of<UserProvider>(context).coin;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: ListView(children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Welcome ',
              style: TextStyle(
                fontSize: 28.sp,
                color: Colors.blue[900],
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                user != null
                    ? Expanded(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const CustomerProfilePage()));
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20.r,
                                    backgroundImage: user.profileImage != null
                                        ? NetworkImage(
                                            '${ApiService.API_URL_FILE}${user.profileImage}')
                                        : const AssetImage(
                                                'assets/images/profile.png')
                                            as ImageProvider,
                                  ),
                                  SizedBox(
                                    width: 8.w,
                                  ),
                                  Text(
                                    'Hi, ${user.name.substring(0, 1).toUpperCase()}${user.name.substring(1).toLowerCase()}',
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      color: Colors.blue[1000],
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                user == null
                    ? Expanded(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pushNamed(
                                        RouteGenerator.technicianRegisterPage);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF642b73),
                                      Color(0xFFc6426e),
                                    ],
                                  ),
                                ),
                                child: Container(
                                  margin: EdgeInsets.all(2.w),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.r),
                                    color: Colors.white,
                                  ),
                                  child: Text(
                                    'Become a Technician',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: Color(0xFF642b73),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pushNamed(RouteGenerator.loginPage);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFC466B),
                                      Color(0xFF3F5EFB),
                                    ],
                                  ),
                                ),
                                child: Container(
                                  margin: EdgeInsets.all(2.w),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.r),
                                    color: Colors.white,
                                  ),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: Color(0xFF3F5EFB),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),

          CustomListTile(
            title: 'About Me',
            icon: Icons.bookmark_outline,
            onTap: () {
              if (user != null) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const TechnicianAboutMe()));
              } else {
                _showLoginFirstDialog(context);
              }
            },
          ),

          CustomListTile(
            title: 'Saved Address',
            icon: Icons.bookmark_outline,
            onTap: () {
              if (user != null) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AddressesPage(
                          isTechinician: true,
                        )));
              } else {
                _showLoginFirstDialog(context);
              }
            },
          ),
          CustomListTile(
            title: 'Account Setting',
            icon: Icons.account_circle_outlined,
            onTap: () {
              if (user != null) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AccountSettingsPage()));
              } else {
                _showLoginFirstDialog(context);
              }
            },
          ),
          CustomListTile(
            title: 'Payment Methods',
            icon: Icons.payment_rounded,
            onTap: () {
              if (user != null) {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ComingSoonPage()));
              } else {
                _showLoginFirstDialog(context);
              }
            },
          ),
          CustomListTile(
            title: 'Notifications',
            icon: Icons.notifications_none_rounded,
            onTap: () {
              if (user != null) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const NotificationsPage()));
              } else {
                _showLoginFirstDialog(context);
              }
            },
          ),
          CustomListTile(
            title: 'Free Credit',
            icon: Icons.credit_score_rounded,
            onTap: () {
              if (user != null) {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ComingSoonPage()));
              } else {
                _showLoginFirstDialog(context);
              }
            },
          ),
          CustomListTile(
            title: 'Online Chat',
            icon: Icons.chat,
            onTap: () {
              if (user != null) {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ComingSoonPage()));
              } else {
                _showLoginFirstDialog(context);
              }
            },
          ),
          CustomListTile(
            title: 'Help Center',
            icon: Icons.help_outline_rounded,
            onTap: () {
              if (user != null) {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ComingSoonPage()));
              } else {
                _showLoginFirstDialog(context);
              }
            },
          ),
          CustomListTile(
            isFinal: true,
            title: 'Language/ቕንቕ',
            icon: Icons.language_rounded,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const LanguageSelectorPage()));
            },
          ),
          // GestureDetector(
          //   onTap: () async {
          //     await Provider.of<UserProvider>(context, listen: false)
          //         .clearUser();
          //     Navigator.of(context, rootNavigator: true)
          //         .pushNamedAndRemoveUntil('/login', (route) => false);
          //   },
          //   child: Container(
          //     margin: EdgeInsets.symmetric(vertical: 8.h),
          //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          //     decoration: BoxDecoration(
          //       color: Colors.red.withOpacity(0.8),
          //       borderRadius: BorderRadius.circular(12.r),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black26,
          //           blurRadius: 4.r,
          //           offset: Offset(2, 2),
          //         ),
          //       ],
          //     ),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Icon(
          //           Icons.logout,
          //           color: Colors.white,
          //           size: 24.sp,
          //         ),
          //         SizedBox(width: 8.w),
          //         Text(
          //           'Log Out',
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontSize: 18.sp,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // )
        ])));
  }

  void _showLoginFirstDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Required'),
          content: Text('Please login first to access this feature.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Login'),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to the login page
                Navigator.of(context, rootNavigator: true)
                    .pushNamed(RouteGenerator.loginPage);
              },
            ),
          ],
        );
      },
    );
  }
}

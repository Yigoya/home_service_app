import 'package:flutter/material.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/account_setting.dart';
import 'package:home_service_app/screens/home/coming_soon.dart';
import 'package:home_service_app/screens/language_selector_page.dart';
import 'package:home_service_app/screens/notification.dart';
import 'package:home_service_app/screens/profile/customer_profile_page.dart';
import 'package:home_service_app/screens/profile/technician_about_me.dart';
import 'package:home_service_app/screens/saved_address.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/utils/route_generator.dart';
import 'package:home_service_app/widgets/customlist_tile.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/l10n/app_localizations.dart';

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
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome ',
              style: TextStyle(
                fontSize: 28.sp,
                color: Color.fromARGB(255, 0, 88, 22),
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
                                    AppLocalizations.of(context)!
                                        .becomeATechnician,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: const Color(0xFF642b73),
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
                                    AppLocalizations.of(context)!.loginSection,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: const Color(0xFF3F5EFB),
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
            title: AppLocalizations.of(context)!.aboutMe,
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
            title: AppLocalizations.of(context)!.savedAddress,
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
            title: AppLocalizations.of(context)!.accountSetting,
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
            title: AppLocalizations.of(context)!.paymentMethods,
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
            title: AppLocalizations.of(context)!.notificationsSection,
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
            title: AppLocalizations.of(context)!.freeCredit,
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
            title: AppLocalizations.of(context)!.onlineChat,
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
            title: AppLocalizations.of(context)!.helpCenter,
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
          //           AppLocalizations.of(context)!.logOut,
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
          title: Text(AppLocalizations.of(context)!.loginRequired),
          content: Text(AppLocalizations.of(context)!.pleaseLoginFirst),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.loginSection),
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

import 'package:flutter/material.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/account_setting.dart';
import 'package:home_service_app/screens/booking/buy_coins_page.dart';
import 'package:home_service_app/screens/home/coming_soon.dart';
import 'package:home_service_app/screens/language_selector_page.dart';
import 'package:home_service_app/screens/notification.dart';
import 'package:home_service_app/screens/payment/checkout_page.dart';
import 'package:home_service_app/screens/profile/customer_profile_page.dart';
import 'package:home_service_app/screens/saved_address.dart';
import 'package:home_service_app/screens/business/business_home_page.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/utils/functions.dart';
import 'package:home_service_app/utils/route_generator.dart';
import 'package:home_service_app/widgets/customlist_tile.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  Widget buildPopupDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 32.h),
            Text(
              AppLocalizations.of(context)!.whatWouldYouLikeToDo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context, rootNavigator: true)
                    .pushNamed(RouteGenerator.signupPage);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              child: Text(
                AppLocalizations.of(context)!.registerAsCustomer,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Center(
              child: Text(
                'or',
                style: TextStyle(fontSize: 16.sp, color: Colors.black54),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context, rootNavigator: true)
                    .pushNamed(RouteGenerator.technicianRegisterPage);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              child: Text(
                AppLocalizations.of(context)!.registerAsTechnicianPrompt,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text:
                    'By creating an account or continuing to use the HuluMoya application, website, or software, you acknowledge and agree that you have accepted the ',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black54,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: AppLocalizations.of(context)!.termsOfService,
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text: ' and have reviewed the ',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  TextSpan(
                    text: AppLocalizations.of(context)!.privacyPolicy,
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text: '.',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final coin = Provider.of<UserProvider>(context).coin;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: 16.h),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                AppLocalizations.of(context)!.welcomeBack,
                style: TextStyle(
                  fontSize: 28.sp,
                  color: Theme.of(context).primaryColor,
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
                  user != null
                      ? GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const BuyCoinsPage()));
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 8.w),
                            padding: EdgeInsets.only(
                                left: 4.w, right: 12.w, top: 4.h, bottom: 4.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color.fromARGB(255, 187, 47, 140),
                                Color.fromARGB(255, 209, 216, 1),
                              ]),
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/coin.png',
                                  width: 20.w,
                                  height: 20.h,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  formatNumber(coin),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
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
                                      .pushNamed(RouteGenerator.loginPage);
                                },
                                child: Container(
                                  margin: EdgeInsets.all(2.w),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.r),
                                    border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                      width: 1.7.w,
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.signIn,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        buildPopupDialog(context),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.all(2.w),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.r),
                                    border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                      width: 1.7.w,
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .registerPrompt,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
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
              fontSize: 20,
              title: AppLocalizations.of(context)!.language,
              icon: Icons.language_rounded,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const LanguageSelectorPage()));
              },
            ),
            CustomListTile(
              title: AppLocalizations.of(context)!.savedAddress,
              icon: Icons.bookmark_outline,
              onTap: () {
                if (user != null) {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddressesPage()));
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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const CheckoutPage(
                            amount: 100,
                          )));
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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ComingSoonPage()));
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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ComingSoonPage()));
                } else {
                  _showLoginFirstDialog(context);
                }
              },
            ),
            CustomListTile(
              isFinal: true,
              title: AppLocalizations.of(context)!.helpCenter,
              icon: Icons.help_outline_rounded,
              onTap: () {
                if (user != null) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ComingSoonPage()));
                } else {
                  _showLoginFirstDialog(context);
                }
              },
            ),
            CustomListTile(
              icon: Icons.business,
              title: "Business Directory",
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BusinessHomePage()));
              },
            ),
            CustomListTile(
              icon: Icons.store,
              title: "B2B Marketplace",
              onTap: () {
                Navigator.pushNamed(context, RouteGenerator.marketplaceHomePage);
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
          ]),
        )));
  }

  void _showLoginFirstDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.youNeedToLoginFirst,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context)!.pleaseLoginFirstToViewDetails,
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true)
                        .pushNamed(RouteGenerator.loginPage);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.loginSection,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

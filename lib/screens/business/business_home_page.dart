import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/provider/notification_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/widgets/slide_show.dart';
import 'package:provider/provider.dart';
import '../../provider/business_provider.dart';
import '../../widgets/app_bar_widget.dart';
import 'business_subcategory_page.dart';
import 'service_details_page.dart';
import 'business_list_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BusinessHomePage extends StatelessWidget {
  const BusinessHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final services =
        Provider.of<HomeServiceProvider>(context).fiterableByCatagory;
    final category = Provider.of<HomeServiceProvider>(context).selectedCategory;
    final location = Provider.of<HomeServiceProvider>(context).selectedLocation;
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarWidget(
        title: 'Just Call',
        showBackButton: true,
        actions: [
          // if (user != null)
          if (true)
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications),
                  Consumer<NotificationProvider>(
                    builder: (context, notificationProvider, child) {
                      final unreadCount = notificationProvider.notifications
                          .where((notification) => !notification.readStatus)
                          .length;
                      return unreadCount > 0
                          ? Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: EdgeInsets.all(2.r),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 14.w,
                                  minHeight: 14.h,
                                ),
                                child: Text(
                                  unreadCount > 9 ? '9+' : '$unreadCount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              onPressed: () {
                if (user != null) {
                  // Load notifications when icon is pressed
                  Provider.of<NotificationProvider>(context, listen: false)
                      .loadNotifications(user.id);
                  // Navigate to notifications page
                  Navigator.pushNamed(context, '/notifications');
                }
              },
            ),
        ],
      ),
      body: ChangeNotifierProvider(
        create: (_) => BusinessProvider(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // // Search section title
              // Padding(
              //   padding: EdgeInsets.only(left: 20.r, right: 20.r, top: 16.r, bottom: 6.r),
              //   child: Row(
              //     children: [
              //       Text(
              //         AppLocalizations.of(context)!.searchForServices,
              //         style: TextStyle(
              //           fontSize: 18.sp,
              //           fontWeight: FontWeight.bold,
              //           color: Colors.black87,
              //         ),
              //       ),
              //       SizedBox(width: 8.w),
              //       Container(
              //         width: 30.w,
              //         height: 3.h,
              //         decoration: BoxDecoration(
              //           gradient: LinearGradient(
              //             colors: [
              //               Theme.of(context).primaryColor,
              //               Colors.teal.shade300,
              //             ],
              //           ),
              //           borderRadius: BorderRadius.circular(10.r),
              //         ),
              //       ),
              //       const Spacer(),
              //       Text(
              //         "${Provider.of<HomeServiceProvider>(context).fiterableByCatagory.length} ${AppLocalizations.of(context)!.servicesSection}",
              //         style: TextStyle(
              //           fontSize: 14.sp,
              //           color: Colors.grey.shade600,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.25),
                        spreadRadius: 2.r,
                        blurRadius: 10.r,
                        offset: Offset(0, 3.h),
                      ),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: Theme.of(context).primaryColor,
                          ),
                    ),
                    child: TextField(
                      cursorColor: Theme.of(context).primaryColor,
                      cursorWidth: 1.5.w,
                      cursorRadius: Radius.circular(2.r),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context) != null
                            ? AppLocalizations.of(context)!.searchForServices
                            : 'Search for services',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 6.w, right: 2.w),
                          child: Icon(
                            Icons.search_rounded,
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.7),
                            size: 24.sp,
                          ),
                        ),
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: IconButton(
                            icon: Icon(
                              Icons.filter_list_rounded,
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.6),
                              size: 24.sp,
                            ),
                            onPressed: () {
                              // Show filters
                            },
                            splashRadius: 24.r,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.2),
                            width: 1.5.w,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 18.h, horizontal: 8.w),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      onChanged: (value) {
                        // Implement search functionality
                        Provider.of<HomeServiceProvider>(context, listen: false)
                            .searchServices(value);
                      },
                    ),
                  ),
                ),
              ),

              // Search results indicator
              Consumer<HomeServiceProvider>(
                builder: (context, provider, child) {
                  final results = provider.fiterableByCatagory;
                  return results.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 48.sp,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  AppLocalizations.of(context)!.serviceNotFound,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                },
              ),

              // Hero image and welcome text
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.r,
                ),
                child: SlideshowComponent(slides: [
                  {
                    'image': 'assets/images/banner2.jpg',
                    'title': 'All in one at huluMoya'
                  },
                  {
                    'image': 'assets/images/banner3.jpg',
                    'title': 'ሁሉም ሞያ በአንድ'
                  },
                  {
                    'image': 'assets/images/banner4.jpg',
                    'title': AppLocalizations.of(context) != null
                        ? AppLocalizations.of(context)!.weAreHereToServeYou
                        : 'Welcome to Just Call',
                  },
                ]),
              ),

              Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Services grid view
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 6 / 6,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.h,
                      ),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return InkWell(
                          onTap: () {
                            // Check if the service has child services
                            if (service.services.isNotEmpty) {
                              // Navigate to ServiceDetailsPage to show child services
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServiceDetailsPage(
                                    service: service,
                                  ),
                                ),
                              );
                            } else {
                              // Navigate to BusinessListPage to show businesses for this service
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BusinessListPage(
                                    service: service,
                                    categoryId: service.id,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
                                  spreadRadius: 1.r,
                                  blurRadius: 3.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                service.icon == null
                                    ? Icon(
                                        [
                                          Icons.home_repair_service,
                                          Icons.cleaning_services,
                                          Icons.electrical_services,
                                          Icons.plumbing,
                                          Icons.construction,
                                          Icons.door_back_door_outlined
                                        ].elementAt(index % 6),
                                        size: 30.sp,
                                      )
                                    : Image.network(
                                        '${ApiService.API_URL_FILE}${service.icon}',
                                        width: 30.w,
                                        height: 30.h,
                                        fit: BoxFit.cover,
                                      ),
                                SizedBox(height: 8.h),
                                Text(
                                  service.name,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/l10n/app_localizations.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/provider/notification_provider.dart';
import 'package:home_service_app/provider/promotion_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/models/promotion.dart';
import 'package:home_service_app/services/api_service.dart';

import 'package:home_service_app/widgets/promotion_card.dart';
import 'package:provider/provider.dart';
import '../../provider/business_provider.dart';
import '../../widgets/app_bar_widget.dart';
import 'business_list_page.dart';

class BusinessHomePage extends StatefulWidget {
  const BusinessHomePage({Key? key}) : super(key: key);

  @override
  State<BusinessHomePage> createState() => _BusinessHomePageState();
}

class _BusinessHomePageState extends State<BusinessHomePage> {
  bool _showAllServices = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Fetch promotions when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromotionProvider>().fetchFeaturedPromotions();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services =
        Provider.of<HomeServiceProvider>(context).fiterableByCatagory;
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarWidget(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        title: 'Yellow Page',
        foregroundColor: Colors.white,
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
              Container(
                padding: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).secondaryHeaderColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25.r),
                    bottomRight: Radius.circular(25.r),
                  ),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
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
                        focusNode: _searchFocusNode,
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
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.7),
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
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
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
                          Provider.of<HomeServiceProvider>(context,
                                  listen: false)
                              .searchServices(value);
                        },
                      ),
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

              // SizedBox(height: 10.h),

              // Promotions section
              /*AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _searchFocusNode.hasFocus ? 0 : null,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _searchFocusNode.hasFocus ? 0.0 : 1.0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.r,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2.r,
                            blurRadius: 8.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Consumer<PromotionProvider>(
                        builder: (context, promotionProvider, child) {
                          if (promotionProvider.isLoading) {
                            return Container(
                              height: 200.h,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            );
                          } else if (promotionProvider.hasPromotions) {
                            return Container(
                              height: 200.h,
                              child: RefreshIndicator(
                                onRefresh: promotionProvider.refreshPromotions,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      promotionProvider.promotions.length,
                                  itemBuilder: (context, index) {
                                    final promotion =
                                        promotionProvider.promotions[index];
                                    return Container(
                                      width: 300.w,
                                      margin: EdgeInsets.only(right: 16.w),
                                      child: PromotionCard(
                                        promotion: promotion,
                                        onTap: () => _onPromotionTap(promotion),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          } else {
                            return Container(
                              height: 200.h,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.local_offer,
                                      size: 48.sp,
                                      color: Colors.grey.shade400,
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      "No special offers available",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      "Check back later for exciting deals!",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    TextButton(
                                      onPressed: promotionProvider
                                          .fetchFeaturedPromotions,
                                      child: Text(
                                        "Refresh",
                                        style: TextStyle(
                                          color: Colors.blue.shade600,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),*/

              // Header with service info (same as service details page)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r).copyWith(bottom: 5.h, top: 5.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage('assets/images/service_ad_bg.jpg'),
                    // Fallback to network image if asset not available
                    onError: (exception, stackTrace) => NetworkImage(
                      'https://images.unsplash.com/photo-1521791055366-0d553872125f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.4),
                      BlendMode.darken,
                    ),
                  ),
                ),
                margin: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_offer,
                          size: 32.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          "SPECIAL OFFERS",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),

                    // Additional promotions section
                    Consumer<PromotionProvider>(
                      builder: (context, promotionProvider, child) {
                        if (promotionProvider.isLoading) {
                          return Container(
                            height: 140.h,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          );
                        } else if (promotionProvider.hasPromotions) {
                          return Container(
                            height: 140.h,
                            child: RefreshIndicator(
                              onRefresh: promotionProvider.refreshPromotions,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: promotionProvider.promotions.length,
                                itemBuilder: (context, index) {
                                  final promotion =
                                      promotionProvider.promotions[index];
                                  return PromotionCard(
                                    promotion: promotion,
                                    onTap: () => _onPromotionTap(promotion),
                                  );
                                },
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            height: 140.h,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "No special offers available",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.white.withOpacity(0.8),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  TextButton(
                                    onPressed: promotionProvider
                                        .fetchFeaturedPromotions,
                                    child: Text(
                                      "Refresh",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),

                    SizedBox(height: 6.h),
                  ],
                ),
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
                        crossAxisCount: 4,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 6.w,
                        mainAxisSpacing: 20.h,
                      ),
                      itemCount: _showAllServices
                          ? services.length
                          : (services.length > 12 ? 12 : services.length),
                      itemBuilder: (context, index) {
                        // Show "More" button at the 12th position (4th row, last item)
                        if (index == 11 &&
                            services.length > 12 &&
                            !_showAllServices) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _showAllServices = true;
                              });
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  size: 42.sp,
                                  // color: Theme.of(context).primaryColor,
                                ),
                                Text(
                                  'See More',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11.sp,
                                    // color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final service = services[index];
                        return InkWell(
                          onTap: () {
                            // Always navigate to BusinessListPage, passing sub-services as sub-categories
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BusinessListPage(
                                  service: service,
                                  categoryId: service.id,
                                  subCategories: service.services,
                                ),
                              ),
                            );
                          },
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
                                      size: 24.sp,
                                    )
                                  : Image.network(
                                      '${ApiService.API_URL_FILE}${service.icon}',
                                      width: 34.w,
                                      height: 34.h,
                                      fit: BoxFit.cover,
                                    ),
                              SizedBox(height: 6.h),
                              Text(
                                service.name,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Show "Show Less" button when all services are displayed
                    if (_showAllServices && services.length > 12)
                      Padding(
                        padding: EdgeInsets.only(top: 16.h),
                        child: Center(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _showAllServices = false;
                                log('service: ${services.toString()}');
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 1.5.w,
                                ),
                                borderRadius: BorderRadius.circular(25.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.keyboard_arrow_up,
                                    size: 20.sp,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Show Less',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.sp,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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

  void _onPromotionTap(Promotion promotion) {
    // Handle promotion tap - could show details, navigate to business, etc.
    print('Promotion tapped: ${promotion.title}');
    // TODO: Implement promotion action - could navigate to business details
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => BusinessDetailsPage(businessId: promotion.businessId),
    //   ),
    // );
  }
}

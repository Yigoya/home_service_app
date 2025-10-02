import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/models/promotion.dart';
import 'package:home_service_app/provider/promotion_provider.dart';
import 'package:home_service_app/widgets/app_bar_widget.dart';
import 'package:home_service_app/widgets/promotion_card.dart';
import 'business_list_page.dart';

class ServiceDetailsPage extends StatefulWidget {
  final Service service;

  const ServiceDetailsPage({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Fetch promotions when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromotionProvider>().fetchFeaturedPromotions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarWidget(
        title: widget.service.name,
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with service info
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

                  // Promotions section
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
                                  onPressed:
                                      promotionProvider.fetchFeaturedPromotions,
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

            // Child services list
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display the child services in a grid
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 6 / 6,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                    ),
                    itemCount: widget.service.services.length,
                    itemBuilder: (context, index) {
                      final childService = widget.service.services[index];
                      return InkWell(
                        onTap: () {
                          // Always navigate to BusinessListPage, passing sub-services as sub-categories
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BusinessListPage(
                                service: childService,
                                categoryId: childService.id,
                                subCategories: childService.services,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1.r,
                                blurRadius: 2.r,
                                offset: Offset(0, 1.h),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              childService.icon == null
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
                                      'https://hulumoya.zapto.org/uploads/${childService.icon}',
                                      width: 30.w,
                                      height: 30.h,
                                      fit: BoxFit.cover,
                                    ),
                              SizedBox(height: 16.h),
                              Text(
                                childService.name,
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

                  // Show a message if there are no child services
                  if (widget.service.services.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.h),
                        child: Text(
                          'No services available',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey,
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

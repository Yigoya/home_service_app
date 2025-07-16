import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/widgets/app_bar_widget.dart';
import 'business_subcategory_page.dart';
import 'business_list_page.dart';

class ServiceDetailsPage extends StatelessWidget {
  final Service service;

  const ServiceDetailsPage({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarWidget(
        title: service.name,
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
              padding: EdgeInsets.all(16.r),
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
                        Icons.campaign,
                        size: 32.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        "ADVERTISEMENT",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Discover exclusive deals on ${service.name} services in your area!",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3.0,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      "Tap to view offers",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
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
                    itemCount: service.services.length,
                    itemBuilder: (context, index) {
                      final childService = service.services[index];
                      return InkWell(
                        onTap: () {
                          if (childService.services.isNotEmpty) {
                            // If this child has its own children, navigate to a new ServiceDetailsPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServiceDetailsPage(
                                  service: childService,
                                ),
                              ),
                            );
                          } else {
                            // Navigate to BusinessListPage to show businesses for this service
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BusinessListPage(
                                  service: childService,
                                  categoryId: childService.id,
                                ),
                              ),
                            );
                          }
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
                                      '${ApiService.API_URL_FILE}${childService.icon}',
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
                  if (service.services.isEmpty)
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
}

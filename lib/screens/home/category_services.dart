import 'package:flutter/material.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/provider/tender_provider.dart';
import 'package:home_service_app/screens/agency/agency_list_screen.dart';
import 'package:home_service_app/screens/home/select_location.dart';
import 'package:home_service_app/screens/home/subcatagory_services.dart';
import 'package:home_service_app/screens/tender/tender_list_page.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryServices extends StatelessWidget {
  const CategoryServices({super.key});

  @override
  Widget build(BuildContext context) {
    final services =
        Provider.of<HomeServiceProvider>(context).fiterableByCatagory;
    final category = Provider.of<HomeServiceProvider>(context).selectedCategory;
    final location = Provider.of<HomeServiceProvider>(context).selectedLocation;
    return Scaffold(
      appBar: category != null && category.id != 3
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              titleSpacing: 0, // Added this line to reduce the space
              title: Row(
                children: [
                  Icon(Icons.location_on_rounded,
                      color: Theme.of(context).primaryColor, size: 24.sp),
                  SizedBox(width: 5.w),
                  Text(AppLocalizations.of(context)!.currentLocation,
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.black.withOpacity(0.8),
                          fontWeight: FontWeight.w500)),
                  SizedBox(width: 5.w),
                  Text(
                      '${Provider.of<HomeServiceProvider>(context, listen: false).subCityNameInLanguage(location, Localizations.localeOf(context))}, Addis Ababa',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            )
          : null,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (category != null && category.id == 3)
                  SizedBox(
                    height: 32.h,
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    category!.icon == null
                        ? Icon(
                            [
                              Icons.home_repair_service,
                              Icons.cleaning_services,
                              Icons.electrical_services,
                              Icons.plumbing,
                              Icons.construction,
                              Icons.door_back_door_outlined
                            ].elementAt(category.id % 4),
                            size: 40.sp,
                            color: Color.fromARGB(255, 0, 88, 22),
                          )
                        : Image.network(
                            '${ApiService.API_URL_FILE}${category.icon}',
                            width: 40.w,
                            height: 40.h,
                            fit: BoxFit.cover,
                            color: Color.fromARGB(255, 0, 88, 22),
                          ),
                    const SizedBox(
                      width: 12,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 106.w,
                          child: Text(
                            category.categoryName,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w900,
                                color: Color.fromARGB(255, 0, 88, 22)),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 106.w,
                          child: Text(
                            category.description ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16.sp, height: 1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // SizedBox(
                //   height: 130.h * (services.length / 3).ceil(),
                //   child: GridView.builder(
                //     physics: const NeverScrollableScrollPhysics(),
                //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                //       crossAxisCount: 3,
                //       childAspectRatio: 6 / 6,
                //       crossAxisSpacing: 10.w,
                //       mainAxisSpacing: 10.h,
                //     ),
                //     itemCount: services.length,
                //     itemBuilder: (context, index) {
                //       return GestureDetector(
                //         onTap: () {
                //           if (category.id == 4) {
                //             Navigator.push(
                //                 context,
                //                 MaterialPageRoute(
                //                     builder: (context) => AgencyListScreen(
                //                         service: services[index])));
                //             return;
                //           }
                //           if (services[index].services.isNotEmpty) {
                //             Navigator.push(
                //                 context,
                //                 MaterialPageRoute(
                //                     builder: (context) => SubCategoryServices(
                //                           service: services[index],
                //                         )));
                //             return;
                //           }
                //           Provider.of<HomeServiceProvider>(context,
                //                   listen: false)
                //               .fetchServiceQuestions(services[index].id);
                //           Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                   builder: (context) => SelectLocation(
                //                       service: services[index])));
                //         },
                //         child: Container(
                //           padding: EdgeInsets.all(8.w),
                //           decoration: BoxDecoration(
                //             color: Colors.white,
                //             borderRadius: BorderRadius.circular(6.r),
                //             boxShadow: [
                //               BoxShadow(
                //                 color: Colors.grey.withOpacity(0.5),
                //                 spreadRadius: 2.r,
                //                 blurRadius: 3.r,
                //                 offset: Offset(0, 2.h),
                //               ),
                //             ],
                //           ),
                //           child: Column(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               services[index].icon == null
                //                   ? Icon(
                //                       [
                //                         Icons.home_repair_service,
                //                         Icons.cleaning_services,
                //                         Icons.electrical_services,
                //                         Icons.plumbing,
                //                         Icons.construction,
                //                         Icons.door_back_door_outlined
                //                       ].elementAt(index % 6),
                //                       size: 30.sp,
                //                       color: Color.fromARGB(255, 0, 88, 22),
                //                     )
                //                   : Image.network(
                //                       '${ApiService.API_URL_FILE}${services[index].icon}',
                //                       width: 30.w,
                //                       height: 30.h,
                //                       fit: BoxFit.cover,
                //                       color: Color.fromARGB(255, 0, 88, 22),
                //                     ),
                //               SizedBox(height: 16.h),
                //               Text(
                //                 services[index].name,
                //                 textAlign: TextAlign.center,
                //                 overflow: TextOverflow.ellipsis,
                //                 maxLines: 2,
                //                 style: TextStyle(
                //                   fontWeight: FontWeight.w600,
                //                   fontSize: 14.sp,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       );
                //     },
                //   ),
                // ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];

                    // Check if the service has child services
                    if (service.services.isNotEmpty) {
                      // Display parent service as a title with its child services
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Parent service as title
                          Padding(
                            padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
                            child: Row(
                              children: [
                                // service.icon == null
                                //     ? Icon(
                                //         [
                                //           Icons.home_repair_service,
                                //           Icons.cleaning_services,
                                //           Icons.electrical_services,
                                //           Icons.plumbing,
                                //           Icons.construction,
                                //           Icons.door_back_door_outlined
                                //         ].elementAt(index % 6),
                                //         size: 24.sp,
                                //         color: Color.fromARGB(255, 0, 88, 22),
                                //       )
                                //     : Image.network(
                                //         '${ApiService.API_URL_FILE}${service.icon}',
                                //         width: 24.w,
                                //         height: 24.h,
                                //         fit: BoxFit.cover,
                                //         color: Color.fromARGB(255, 0, 88, 22),
                                //       ),
                                // SizedBox(width: 8.w),
                                Text(
                                  service.name,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 0, 88, 22),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // SizedBox(height: 8.h),
                          Divider(color: Colors.grey.withOpacity(0.3)),
                          SizedBox(
                            height: 16.h,
                          ),
                          // Child services
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 6 / 6,
                              crossAxisSpacing: 10.w,
                              mainAxisSpacing: 10.h,
                            ),
                            itemCount: service.services.length,
                            itemBuilder: (context, childIndex) {
                              final childService = service.services[childIndex];
                              print(
                                  '${ApiService.API_URL_FILE}${childService.icon}');
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SelectLocation(
                                              service: services[index])));
                                },
                                child: Container(
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
                                              ].elementAt(childIndex % 6),
                                              size: 24.sp,
                                            )
                                          : Image.network(
                                              '${ApiService.API_URL_FILE}${childService.icon}',
                                              width: 24.w,
                                              height: 24.h,
                                              fit: BoxFit.cover,
                                            ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        childService.name,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height: 16.h,
                          )
                        ],
                      );
                    } else {
                      // Display the service as a normal grid item
                      return InkWell(
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) =>
                          //             BusinessSubcategoryPage(
                          //               categoryId: service.id,
                          //               categoryName: service.name,
                          //             )));
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          padding: EdgeInsets.all(16.r),
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
                          child: Row(
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
                                      color: Colors.blue.shade700,
                                    )
                                  : Image.network(
                                      '${ApiService.API_URL_FILE}${service.icon}',
                                      width: 24.w,
                                      height: 24.h,
                                      fit: BoxFit.cover,
                                      color: Colors.blue.shade700,
                                    ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Text(
                                  service.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16.sp,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

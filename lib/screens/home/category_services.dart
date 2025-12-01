import 'package:flutter/material.dart';
import 'package:home_service_app/models/service.dart';
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
import 'package:home_service_app/l10n/app_localizations.dart';

class CategoryServices extends StatefulWidget {
  const CategoryServices({super.key});

  @override
  State<CategoryServices> createState() => _CategoryServicesState();
}

class _CategoryServicesState extends State<CategoryServices> {
  bool _showAllRepairServices = false;
  // Add state variables for other GridViews
  Map<int, bool> _expandedServices = {};
  Map<String, bool> _expandedChildServices = {};

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
                      color: Theme.of(context).secondaryHeaderColor,
                      size: 24.sp),
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
                        color: Theme.of(context).secondaryHeaderColor,
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
                            color: Theme.of(context).secondaryHeaderColor,
                          )
                        : Image.network(
                            '${ApiService.API_URL_FILE}${category.icon}',
                            width: 40.w,
                            height: 40.h,
                            fit: BoxFit.cover,
                            color: Theme.of(context).secondaryHeaderColor,
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
                                color: Theme.of(context).secondaryHeaderColor),
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
                // Special handling for maintenance category (category.id != 3)
                if (category.id != 3) ...[
                  // First, show "Home keeping" subcategory if it exists
                  ...services
                      .where((service) =>
                          service.name.toLowerCase().contains('home keeping'))
                      .map((service) =>
                          _buildServiceItem(service, services, context))
                      .toList(),

                  // Then show "Repair and Installment" section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "Repair and Installment" section header
                      Padding(
                        padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
                        child: Text(
                          "Repair and Installment",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 88, 22),
                          ),
                        ),
                      ),
                      Divider(color: Colors.grey.withOpacity(0.3)),
                      // SizedBox(height: 16.h),

                      // Combined grid for repair services with collapsible functionality
                      Column(
                        children: [
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 6 / 6,
                              crossAxisSpacing: 10.w,
                              mainAxisSpacing: 10.h,
                            ),
                            itemCount: _showAllRepairServices
                                ? _getCombinedRepairServices(services).length
                                : 8, // Show first 2 rows (4 items per row = 8 items)
                            itemBuilder: (context, childIndex) {
                              final combinedServices =
                                  _getCombinedRepairServices(services);

                              // If we're showing limited items and this is the 8th item, show "More" button
                              if (!_showAllRepairServices &&
                                  childIndex == 7 &&
                                  combinedServices.length > 8) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _showAllRepairServices = true;
                                    });
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                        size: 34.sp,
                                        // color: Theme.of(context).primaryColor,
                                      ),
                                      Text(
                                        'See More',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14.sp,
                                          // color:
                                          //     Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              // Show regular service item
                              final childService = combinedServices[childIndex];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SelectLocation(
                                              service: childService)));
                                },
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
                                            width: 34.w,
                                            height: 34.h,
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
                              );
                            },
                          ),

                          // Show "Show Less" button when all items are displayed
                          if (_showAllRepairServices &&
                              _getCombinedRepairServices(services).length > 8)
                            Padding(
                              padding: EdgeInsets.only(top: 16.h),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _showAllRepairServices = false;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.h, horizontal: 16.w),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.3),
                                      width: 1.w,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.keyboard_arrow_up,
                                        size: 16.sp,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'Show Less',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),

                  // Display other services (non-repair services and non-home keeping services) as normal
                  ...services
                      .where((service) {
                        bool isRepair = _isRepairService(service.name);
                        bool isHomeKeeping =
                            service.name.toLowerCase().contains('home keeping');
                        print(
                            'Filtering service "${service.name}": isRepair = $isRepair, isHomeKeeping = $isHomeKeeping');
                        return !isRepair && !isHomeKeeping;
                      })
                      .map((service) =>
                          _buildServiceItem(service, services, context))
                      .toList(),
                ] else ...[
                  // Original logic for professional category (category.id == 3)
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
                            Divider(color: Colors.grey.withOpacity(0.3)),
                            SizedBox(height: 16.h),
                            // Child services
                            GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 6 / 6,
                                crossAxisSpacing: 10.w,
                                mainAxisSpacing: 10.h,
                              ),
                              itemCount: _expandedServices[service.id] == true
                                  ? service.services.length
                                  : (service.services.length > 8
                                      ? 8
                                      : service.services.length),
                              itemBuilder: (context, childIndex) {
                                final childService =
                                    service.services[childIndex];

                                // If we're showing limited items and this is the 8th item, show "More" button
                                if (_expandedServices[service.id] != true &&
                                    childIndex == 7 &&
                                    service.services.length > 8) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _expandedServices[service.id] = true;
                                      });
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.keyboard_arrow_down_outlined,
                                          size: 34.sp,
                                        ),
                                        Text(
                                          'See More',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SelectLocation(
                                                    service: services[index])));
                                  },
                                  child: Container(
                                    // decoration: BoxDecoration(
                                    //   color: Colors.white,
                                    //   borderRadius: BorderRadius.circular(6.r),
                                    //   boxShadow: [
                                    //     BoxShadow(
                                    //       color: Colors.grey.withOpacity(0.3),
                                    //       spreadRadius: 1.r,
                                    //       blurRadius: 2.r,
                                    //       offset: Offset(0, 1.h),
                                    //     ),
                                    //   ],
                                    // ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                size: 34.sp,
                                              )
                                            : Image.network(
                                                '${ApiService.API_URL_FILE}${childService.icon}',
                                                width: 34.w,
                                                height: 34.h,
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

                            // Show "Show Less" button when all items are displayed
                            if (_expandedServices[service.id] == true &&
                                service.services.length > 8)
                              Padding(
                                padding: EdgeInsets.only(top: 16.h),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _expandedServices[service.id] = false;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8.h, horizontal: 16.w),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.3),
                                        width: 1.w,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.keyboard_arrow_up,
                                          size: 16.sp,
                                          color: Colors.grey[600],
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          'Show Less',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(height: 16.h)
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
                                        size: 30.sp,
                                        color: Theme.of(context).primaryColor,
                                      )
                                    : Image.network(
                                        '${ApiService.API_URL_FILE}${service.icon}',
                                        width: 34.w,
                                        height: 34.h,
                                        fit: BoxFit.cover,
                                        color: Theme.of(context).primaryColor,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to check if a service is a repair service
  bool _isRepairService(String serviceName) {
    final repairServiceNames = [
      'Popular Repair services',
      'Popular Repair Services',
      'Popular repair services',
      'Plumbing',
      'Appliance Repair',
      'Appliance repair',
      'repair',
      'Repair',
    ];

    // Debug print to see what service names we're checking
    print('Checking service: "$serviceName"');

    bool isRepair = repairServiceNames
        .any((name) => serviceName.toLowerCase().contains(name.toLowerCase()));

    print('Is repair service: $isRepair');
    return isRepair;
  }

  // Helper method to get combined repair services from all services
  List<Service> _getCombinedRepairServices(List<Service> services) {
    List<Service> combinedServices = [];

    print('Total services to check: ${services.length}');

    for (var service in services) {
      print('Processing service: "${service.name}"');
      if (_isRepairService(service.name)) {
        print('Found repair service: "${service.name}"');
        if (service.services.isNotEmpty) {
          // If the service has child services, add them
          print(
              'Adding ${service.services.length} child services from "${service.name}"');
          combinedServices.addAll(service.services);
        } else {
          // If it's a standalone service, add it directly
          print('Adding standalone service: "${service.name}"');
          combinedServices.add(service);
        }
      }
    }

    print('Total combined repair services: ${combinedServices.length}');
    return combinedServices;
  }

  // Helper method to build service items for non-repair services
  Widget _buildServiceItem(
      Service service, List<Service> allServices, BuildContext context) {
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
          Divider(color: Colors.grey.withOpacity(0.3)),
          // Child services
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 6 / 6,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
            ),
            itemCount: _expandedChildServices[service.name] == true
                ? service.services.length
                : (service.services.length > 8 ? 8 : service.services.length),
            itemBuilder: (context, childIndex) {
              final childService = service.services[childIndex];

              // If we're showing limited items and this is the 8th item, show "More" button
              if (_expandedChildServices[service.name] != true &&
                  childIndex == 7 &&
                  service.services.length > 8) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _expandedChildServices[service.name] = true;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.keyboard_arrow_down_outlined,
                        size: 34.sp,
                      ),
                      Text(
                        'See More',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SelectLocation(service: service)));
                },
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
                            width: 34.w,
                            height: 34.h,
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
              );
            },
          ),

          // Show "Show Less" button when all items are displayed
          if (_expandedChildServices[service.name] == true &&
              service.services.length > 8)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _expandedChildServices[service.name] = false;
                  });
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.keyboard_arrow_up,
                        size: 16.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Show Less',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SizedBox(height: 16.h)
        ],
      );
    } else {
      // Display the service as a normal list item
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
                      ].elementAt(0),
                      size: 30.sp,
                      color: Theme.of(context).primaryColor,
                    )
                  : Image.network(
                      '${ApiService.API_URL_FILE}${service.icon}',
                      width: 34.w,
                      height: 34.h,
                      fit: BoxFit.cover,
                      color: Theme.of(context).primaryColor,
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
  }
}

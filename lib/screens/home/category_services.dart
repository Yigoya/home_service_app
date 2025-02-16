import 'package:flutter/material.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/provider/tender_provider.dart';
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
                        Text(
                          category.categoryName,
                          style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w900,
                              color: Color.fromARGB(255, 0, 88, 22)),
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
                SizedBox(height: 40.h),
                SizedBox(
                  height: 130.h * (services.length / 3).ceil(),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 6 / 6,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (category.id == 3) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TenderListPage(
                                        service: services[index])));
                            return;
                          }
                          if (services[index].hasChild) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SubCategoryServices(
                                          service: services[index],
                                        )));
                            return;
                          }
                          Provider.of<HomeServiceProvider>(context,
                                  listen: false)
                              .fetchServiceQuestions(services[index].id);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SelectLocation(
                                      service: services[index])));
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2.r,
                                blurRadius: 3.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              services[index].icon == null
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
                                      color: Color.fromARGB(255, 0, 88, 22),
                                    )
                                  : Image.network(
                                      '${ApiService.API_URL_FILE}${services[index].icon}',
                                      width: 30.w,
                                      height: 30.h,
                                      fit: BoxFit.cover,
                                      color: Color.fromARGB(255, 0, 88, 22),
                                    ),
                              SizedBox(height: 16.h),
                              Text(
                                services[index].name,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

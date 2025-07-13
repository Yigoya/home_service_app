import 'package:flutter/material.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/screens/home/select_location.dart';
import 'package:home_service_app/screens/tender/tender_list_page.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class SubCategoryServices extends StatefulWidget {
  final Service service;

  SubCategoryServices({required this.service});

  @override
  State<SubCategoryServices> createState() => _SubCategoryServicesState();
}

class _SubCategoryServicesState extends State<SubCategoryServices> {
  @override
  Widget build(BuildContext context) {
    final location = Provider.of<HomeServiceProvider>(context).selectedLocation;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(service.name),
      // ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 32.sp,
                        ),
                      ),

                      Text(
                        AppLocalizations.of(context)!.services,
                        style: TextStyle(
                          fontSize: 28.sp,
                          // fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      // Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(context)
                            .popUntil((route) => route.isFirst),
                        child: Icon(
                          Icons.other_houses_outlined,
                          color: Colors.white,
                          size: 32.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        AppLocalizations.of(context)!.currentLocation,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        Provider.of<HomeServiceProvider>(context, listen: false)
                            .subCityNameInLanguage(
                                location, Localizations.localeOf(context)),
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 32.w,
                    child: Text(
                      widget.service.name,
                      style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 32.w,
                    child: Text(
                      widget.service.description ?? '',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<Service>>(
                future: Provider.of<HomeServiceProvider>(context, listen: false)
                    .loadSubServices(widget.service.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No services available'));
                  }

                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final subService = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            if (subService.hasChild) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SubCategoryServices(
                                            service: subService,
                                          )));
                              return;
                            }
                            if (subService.categoryId == 3) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          TenderListPage(service: subService)));
                              return;
                            }

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SelectLocation(service: subService)));
                          },
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            margin: EdgeInsets.symmetric(
                                vertical: 4.h, horizontal: 16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width -
                                          86.w,
                                      child: Text(
                                        subService.name,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width -
                                          86.w,
                                      child: Text(
                                        subService.description ?? '',
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20.sp,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}

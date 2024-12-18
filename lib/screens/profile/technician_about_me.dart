import 'package:flutter/material.dart';
import 'package:home_service_app/provider/profile_page_provider.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TechnicianAboutMe extends StatelessWidget {
  const TechnicianAboutMe({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ProfilePageProvider>(context).techinicianDetail;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              '${ApiService.API_URL_FILE}${data['profileImage']}',
              height: 250.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            // Profile Section
            Container(
              padding: EdgeInsets.all(16.w),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1.w,
                    blurRadius: 5.w,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data['name'],
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < data['rating']
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20.sp,
                          ),
                        ),
                      )
                    ],
                  ),
                  Text(data['email'],
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold)),
                  Text(data['phoneNumber'],
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 10.h),
                  Text(
                    data['bio'] ?? 'No bio available',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Service Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                "Services",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Wrap(
              spacing: 5.w,
              runSpacing: 6.h,
              children: data['services']
                  .map<Widget>(
                    (service) => Container(
                      width: (12 * service['name'].length).toDouble().w,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      margin: EdgeInsets.only(left: 8.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Center(
                        child: Text(
                          service['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

            SizedBox(height: 16.h),

            // Weekly Schedule Section
            Container(
              padding: EdgeInsets.all(16.w),
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32.r),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Text(
                    "Weekly Schedule",
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  data['weeklySchedule'] != null
                      ? DataTable(
                          columns: [
                            DataColumn(
                                label: Text('Day',
                                    style: TextStyle(fontSize: 14.sp))),
                            DataColumn(
                                label: Text('Start',
                                    style: TextStyle(fontSize: 14.sp))),
                            DataColumn(
                                label: Text('End',
                                    style: TextStyle(fontSize: 14.sp))),
                          ],
                          rows: [
                            ...[
                              'Monday',
                              'Tuesday',
                              'Wednesday',
                              'Thursday',
                              'Friday',
                              'Saturday',
                              'Sunday'
                            ].map((day) {
                              final start = data['weeklySchedule']
                                  ["${day.toLowerCase()}Start"];
                              final end = data['weeklySchedule']
                                  ["${day.toLowerCase()}End"];
                              return DataRow(
                                cells: [
                                  DataCell(Text(day,
                                      style: TextStyle(fontSize: 14.sp))),
                                  DataCell(Text(start ?? '-',
                                      style: TextStyle(fontSize: 14.sp))),
                                  DataCell(Text(end ?? '-',
                                      style: TextStyle(fontSize: 14.sp))),
                                ],
                              );
                            }),
                          ],
                        )
                      : Text("No schedule available",
                          style: TextStyle(fontSize: 14.sp)),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32.r),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Saved Address",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  ...data['address'].map<Widget>((address) => Container(
                        padding: EdgeInsets.all(8.w),
                        margin: EdgeInsets.only(top: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Country : ${address['country'] ?? 'Ethiopia'}',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            Text(
                              'City : ${address['city'] ?? 'Addis Ababa'}',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            Text(
                              'Sub City : ${address['subcity'] ?? '-'}',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            Text(
                              'Wereda : ${address['wereda'] ?? '-'}',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ))
                ],
              ),
            ),
            SizedBox(
              height: 64.h,
            )
          ],
        ),
      ),
    );
  }
}

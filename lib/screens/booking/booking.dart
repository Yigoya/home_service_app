import 'package:flutter/material.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/models/technician.dart';
import 'package:home_service_app/provider/booking_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/utils/functions.dart';
import 'package:home_service_app/utils/route_generator.dart';
import 'package:home_service_app/widgets/custom_button.dart';
import 'package:home_service_app/widgets/custom_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookingPage extends StatefulWidget {
  final Technician technician;
  final Service service;

  const BookingPage(
      {super.key, required this.technician, required this.service});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? selectedDate;
  final TextEditingController jobDescriptionController =
      TextEditingController();

  final dropDownKey = GlobalKey<DropdownSearchState>();
  final dropDownKey2 = GlobalKey<DropdownSearchState>();
  String? selectedSubCity;
  String? selectedWereda;

  @override
  void dispose() {
    jobDescriptionController.dispose();
    super.dispose();
  }

  void bookService() async {
    if (jobDescriptionController.text.isEmpty) {
      showTopMessage(context, AppLocalizations.of(context)!.pleaseDescribeJob,
          isWaring: true);
      return;
    }
    final customerId =
        Provider.of<UserProvider>(context, listen: false).customer!.id;
    final bookingData = {
      'customerId': customerId,
      'technicianId': widget.technician.id,
      'serviceId': widget.service.id,
      'city': 'Addis Ababa',
      'description': jobDescriptionController.text,
    };

    // Send bookingData to the backend
    final res = await Provider.of<BookingProvider>(context, listen: false)
        .bookService(bookingData, context);
    if (res) {
      showBookingSuccessDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: 48.h, left: 16.w, right: 16.w),
              padding: EdgeInsets.all(16.0.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 20.h,
                  ),
                  CircleAvatar(
                    radius: 50.r,
                    backgroundImage: NetworkImage(
                        '${ApiService.API_URL_FILE}${widget.technician.profileImage}'), // replace with actual image source
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    widget.technician.name,
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      widget.service.name,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Address Selector

                  SizedBox(height: 36.h),

                  // Job Description
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: TextField(
                      controller: jobDescriptionController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!
                            .describeJobTask, // 'Describe Job Task',

                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12.w),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24.h,
                  ),

                  CustomButton(
                    onLoad: () {},
                    isLoading: Provider.of<BookingProvider>(context).isLoading,
                    text: AppLocalizations.of(context)!
                        .bookService, // 'Book Service',
                    onTap: bookService,
                  ),
                ],
              ),
            ),
            Positioned(
                right: 16.w,
                top: 48.h,
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close, size: 24.sp)))
          ],
        ),
      ),
    );
  }

  Future<void> showBookingSuccessDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // Close when tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
              SizedBox(width: 10.w),
              Text(AppLocalizations.of(context)!.bookingConfirmed),
            ],
          ),
          content: Text(AppLocalizations.of(context)!.bookingSuccess),
          actions: <Widget>[
            TextButton(
              child: Text('OK',
                  style: TextStyle(color: Colors.green, fontSize: 12.sp)),
              onPressed: () {
                Navigator.pushNamed(context, RouteGenerator.homePage);
              },
            ),
          ],
        );
      },
    );
  }
}

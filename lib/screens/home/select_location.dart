import 'package:flutter/material.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/provider/booking_provider.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/screens/home/technician_filter.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/widgets/custom_button.dart';
import 'package:home_service_app/widgets/custom_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectLocation extends StatefulWidget {
  final Service service;
  const SelectLocation({super.key, required this.service});

  @override
  State<SelectLocation> createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  String? selectedSubCity;
  String? selectedWereda;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = Provider.of<HomeServiceProvider>(context, listen: false)
          .selectedLocation;
      Provider.of<BookingProvider>(context, listen: false).setSelectedSubCity(
          Provider.of<HomeServiceProvider>(context, listen: false)
              .subCityNameInLanguage(
                  location, Localizations.localeOf(context)));
      setState(() {
        selectedSubCity = Provider.of<HomeServiceProvider>(context,
                listen: false)
            .subCityNameInLanguage(location, Localizations.localeOf(context));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = Provider.of<HomeServiceProvider>(context).selectedLocation;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
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
                          AppLocalizations.of(context)!.location,
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
                          Provider.of<HomeServiceProvider>(context,
                                  listen: false)
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
                padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 12.h,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.service.icon == null
                              ? Icon(
                                  [
                                    Icons.home_repair_service,
                                    Icons.cleaning_services,
                                    Icons.electrical_services,
                                    Icons.plumbing,
                                    Icons.construction,
                                    Icons.door_back_door_outlined
                                  ].elementAt(widget.service.id % 6),
                                  size: 40.sp,
                                  color: Color.fromARGB(255, 0, 88, 22),
                                )
                              : Image.network(
                                  '${ApiService.API_URL_FILE}${widget.service.icon}',
                                  width: 40.w,
                                  height: 40.h,
                                  fit: BoxFit.cover,
                                  color: Theme.of(context).primaryColor,
                                ),
                          SizedBox(width: 10.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width - 106.w,
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
                                width:
                                    MediaQuery.of(context).size.width - 106.w,
                                child: Text(
                                  widget.service.description ?? '',
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16.h,
                      ),
                      Text(
                        AppLocalizations.of(context)!.whatIsTaskLocation,
                        style: TextStyle(
                            fontSize: 24.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20.h),
                      CustomDropdown(
                        items: Provider.of<HomeServiceProvider>(context,
                                listen: false)
                            .subCitys(Localizations.localeOf(context)),
                        hint: AppLocalizations.of(context)!.selectYourSubCity,
                        selectedValue: selectedSubCity,
                        onChanged: (value) {
                          setState(() {
                            selectedSubCity = value;
                            Provider.of<BookingProvider>(context, listen: false)
                                .setSelectedSubCity(value);
                          });
                        },
                      ),
                      SizedBox(
                        height: 16.h,
                      ),
                      CustomDropdown(
                        items:
                            Provider.of<HomeServiceProvider>(context).weredas,
                        hint: AppLocalizations.of(context)!.selectYourWereda,
                        selectedValue: selectedWereda,
                        onChanged: (value) {
                          setState(() {
                            selectedWereda = value;
                            Provider.of<BookingProvider>(context, listen: false)
                                .setSelectedWereda(value);
                          });
                        },
                      ),
                      const Spacer(),
                      CustomButton(
                        onLoad: () {},
                        isLoading:
                            Provider.of<BookingProvider>(context).isLoading,
                        text: AppLocalizations.of(context)!
                            .conti, // : AppLocalizations.of(context)!.bookServicePrompt,
                        borderRadius: 32.r,
                        color: Theme.of(context).primaryColor,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => TechnicianFilter(
                                        service: widget.service,
                                        selectedDate: DateTime.now(),
                                        selectedTime: TimeOfDay.now(),
                                      )));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

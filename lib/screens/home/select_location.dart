import 'package:flutter/material.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/provider/booking_provider.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/screens/home/technician_filter.dart';
import 'package:home_service_app/widgets/custom_button.dart';
import 'package:home_service_app/widgets/custom_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      final location =
          Provider.of<HomeServiceProvider>(context, listen: false).location;
      Provider.of<BookingProvider>(context, listen: false)
          .setSelectedSubCity(location['subcity'] as String?);
      setState(() {
        selectedSubCity = location['subcity'] as String? ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: SizedBox.shrink(),
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            widget.service.name,
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w500),
          ),
          actions: [
            IconButton(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 16.h,
              ),
              Text(
                "What is the task location",
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              CustomDropdown(
                items: Provider.of<HomeServiceProvider>(context).subCitys,
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
                items: Provider.of<HomeServiceProvider>(context).weredas,
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
                isLoading: Provider.of<BookingProvider>(context).isLoading,
                text: "Continue", // 'Book Service',
                onTap: () {
                  // Provider.of<HomeServiceProvider>(context, listen: false)
                  //     .loadTechnicians(widget.service.id);
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
        ));
  }
}

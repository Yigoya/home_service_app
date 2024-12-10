import 'package:flutter/material.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/models/technician.dart';
import 'package:home_service_app/provider/auth_provider.dart';
import 'package:home_service_app/provider/booking_provider.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/booking/booking.dart';
import 'package:home_service_app/screens/profile/technician_detail_page.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/utils/route_generator.dart';
import 'package:home_service_app/widgets/custom_button.dart';
import 'package:home_service_app/widgets/custom_dropdown.dart';
import 'package:home_service_app/widgets/pagination.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TechnicianFilter extends StatefulWidget {
  final Service service;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;

  const TechnicianFilter({
    super.key,
    required this.service,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  State<TechnicianFilter> createState() => _TechnicianFilterState();
}

class _TechnicianFilterState extends State<TechnicianFilter> {
  String? nameFilter;
  String? selectedSubCity;
  String? selectedWereda;
  double? minPrice;
  double? maxPrice;
  double? minRating;
  int page = 1;
  int size = 9;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      print(_focusNode.hasFocus);
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Logger().d('Selected Date: ${widget.selectedDate}');
      setState(() {
        selectedSubCity = Provider.of<BookingProvider>(context, listen: false)
            .selectedSubCity;
        selectedWereda =
            Provider.of<BookingProvider>(context, listen: false).selectedWereda;
      });
      fetchTechnicians();
    });
  }

  Future<void> fetchTechnicians() async {
    // Construct query parameters
    final queryParameters = {
      if (controller.text.isNotEmpty) 'name': controller.text,
      if (selectedSubCity != null) 'subCity': selectedSubCity,
      if (selectedWereda != null) 'wereda': selectedWereda,
      if (widget.selectedDate != null)
        'date':
            "${widget.selectedDate!.year}-${widget.selectedDate!.month.toString().padLeft(2, '0')}-${widget.selectedDate!.day.toString().padLeft(2, '0')}",
      if (widget.selectedTime != null)
        'time':
            "${widget.selectedTime!.hour.toString().padLeft(2, '0')}:${widget.selectedTime!.minute.toString().padLeft(2, '0')}",
      'page': page - 1,
      'size': size
      // if (minPrice != null) 'minPrice': minPrice.toString(),
      // if (maxPrice != null) 'maxPrice': maxPrice.toString(),
      // if (minRating != null) 'minRating': minRating.toString(),
    };

    // Fetch technicians
    await Provider.of<HomeServiceProvider>(context, listen: false)
        .filterTechnician(queryParameters);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 16.h,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: _isFocused
                            ? Border.all(color: Colors.blue, width: 1.5.w)
                            : Border.all(
                                color:
                                    const Color.fromARGB(255, 228, 228, 228)),
                      ),
                      child: TextField(
                        controller: controller,
                        focusNode: _focusNode,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          hintText: AppLocalizations.of(context)!.searchByName,
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 20.sp),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            onPressed: () {
                              fetchTechnicians();
                            },
                            icon: Icon(Icons.search,
                                color: Colors.black.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    CustomDropdown(
                      items: const ["Bole", "Akaki", "Nifas Silk"],
                      hint: AppLocalizations.of(context)!.selectYourSubCity,
                      selectedValue: selectedSubCity,
                      onChanged: (value) {
                        setState(() {
                          selectedSubCity = value;
                        });
                      },
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    CustomDropdown(
                      items: const ["01", "02", "03", "04", "05"],
                      hint: AppLocalizations.of(context)!.selectYourWereda,
                      selectedValue: selectedWereda,
                      onChanged: (value) {
                        setState(() {
                          selectedWereda = value;
                        });
                      },
                    ),
                    SizedBox(height: 16.h),
                    CustomButton(
                      onLoad: () {},
                      text: AppLocalizations.of(context)!.applyFilters,
                      onTap: fetchTechnicians,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 32.h,
              ),
              Text(
                '${Provider.of<HomeServiceProvider>(context).totalElements} technicians found matching your specifications',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Consumer<HomeServiceProvider>(
                builder: (context, provider, child) {
                  const height = 270.0;
                  if (provider.isLoading) {
                    return SizedBox(
                        height: 460.h,
                        child:
                            const Center(child: CircularProgressIndicator()));
                  } else {
                    return SizedBox(
                      height: (height + 16.h) * provider.technicians.length,
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.technicians.length,
                        itemBuilder: (context, index) {
                          final technician = provider.technicians[index];

                          return _buildTechnicianCard(technician, height);
                        },
                      ),
                    );
                  }
                },
              ),
              // Pagination Controls
              Pagination(
                totalPage: Provider.of<HomeServiceProvider>(context).totalPages,
                currentPage: page,
                onPageChanged: (currentPage) {
                  setState(() {
                    page = currentPage;
                  });
                  fetchTechnicians();
                },
              ),
              SizedBox(
                height: 52.h,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicianCard(Technician tech, double height) {
    return Container(
      width: 320.w,
      height: height.h,
      margin: EdgeInsets.only(left: 16.w, top: 16.h, right: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
                color: Colors.grey[200]!,
                offset: const Offset(0, 2),
                blurRadius: 2)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0.r),
                child: Image.network(
                  '${ApiService.API_URL_FILE}${tech.profileImage}',
                  fit: BoxFit.cover,
                  width: 72.w,
                  height: 72.h,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/profile.png',
                      width: 72.w,
                      height: 72.h,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tech.name ?? 'No Name',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  SizedBox(
                    height: 30.h,
                    width: MediaQuery.of(context).size.width - 150.w,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: tech.services
                              .map((service) => Container(
                                    margin: EdgeInsets.only(right: 8.w),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      service.name,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp),
                                    ),
                                  ))
                              .toList() ??
                          [],
                    ),
                  )
                ],
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            tech.bio ?? 'No bio available',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              if (tech.subcity != null || tech.city != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.location,
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.grey, size: 16),
                        SizedBox(width: 5.w),
                        Text(
                          '${tech.subcity ?? ''}, ${tech.city ?? ''}',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              SizedBox(width: 20.w),
              Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.rating,
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Color.fromARGB(255, 235, 173, 5), size: 16),
                      SizedBox(width: 5.w),
                      Text(
                        '${tech.rating ?? 0}',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TechncianDetailPage(
                                technicianId: tech.id,
                              )));
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.h, horizontal: 24.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(AppLocalizations.of(context)!.viewProfile,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 18.sp)),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: InkWell(
                  onTap: () async {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => BookingPage(
                            technician: tech, service: widget.service)));

                    final user =
                        Provider.of<UserProvider>(context, listen: false).user;
                    if (user == null) {
                      Provider.of<AuthenticationProvider>(context,
                              listen: false)
                          .setFromAnotherPage(true);
                      Navigator.of(context, rootNavigator: true)
                          .pushNamed(RouteGenerator.loginPage);
                    }
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                    child: Text(AppLocalizations.of(context)!.selectAndContinue,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18.sp)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

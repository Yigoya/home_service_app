import 'package:flutter/material.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/models/technician.dart';
import 'package:home_service_app/provider/auth_provider.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/booking/booking.dart';
import 'package:home_service_app/screens/profile/technician_detail_page.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/utils/route_generator.dart';
import 'package:home_service_app/widgets/custom_button.dart';
import 'package:home_service_app/widgets/custom_dropdown.dart';
import 'package:home_service_app/widgets/pagination.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    fetchTechnicians();
    _focusNode.addListener(() {
      print(_focusNode.hasFocus);
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
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
              const SizedBox(
                height: 16,
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: _isFocused
                            ? Border.all(color: Colors.blue, width: 1.5)
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
                              const TextStyle(color: Colors.grey, fontSize: 20),
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
                    const SizedBox(
                      height: 8,
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
                    const SizedBox(
                      height: 8,
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
                    const SizedBox(height: 16),
                    CustomButton(
                      onLoad: () {},
                      text: AppLocalizations.of(context)!.applyFilters,
                      onTap: fetchTechnicians,
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 32,
              ),
              Text(
                '${Provider.of<HomeServiceProvider>(context).totalElements} technicians found matching your specifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Consumer<HomeServiceProvider>(
                builder: (context, provider, child) {
                  const height = 270.0;
                  if (provider.isLoading) {
                    return const SizedBox(
                        height: 460,
                        child: Center(child: CircularProgressIndicator()));
                  } else {
                    return SizedBox(
                      height: (height + 16) * provider.technicians.length,
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
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicianCard(Technician tech, double height) {
    return Container(
      width: 320,
      height: height,
      margin: const EdgeInsets.only(left: 16, top: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  '${ApiService.API_URL_FILE}${tech.profileImage}',
                  fit: BoxFit.cover,
                  width: 72,
                  height: 72,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/profile.png',
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tech.name ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    width: MediaQuery.of(context).size.width - 150,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: tech.services
                              .map((service) => Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      service.name,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
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
          const SizedBox(height: 6),
          Text(
            tech.bio ?? 'No bio available',
            style: const TextStyle(
              fontSize: 16,
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
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.grey, size: 16),
                        const SizedBox(width: 5),
                        Text(
                          '${tech.subcity ?? ''}, ${tech.city ?? ''}',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(width: 20),
              Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.rating,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Color.fromARGB(255, 235, 173, 5), size: 16),
                      const SizedBox(width: 5),
                      Text(
                        '${tech.rating ?? 0}',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
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
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(AppLocalizations.of(context)!.viewProfile,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 18)),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(16),
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
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Text(AppLocalizations.of(context)!.selectAndContinue,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18)),
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

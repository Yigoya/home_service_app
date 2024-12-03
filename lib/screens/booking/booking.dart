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
    if (selectedSubCity == null) {
      showTopMessage(context, AppLocalizations.of(context)!.pleaseSelectSubCity,
          isWaring: true);
      return;
    }

    if (selectedWereda == null) {
      showTopMessage(context, AppLocalizations.of(context)!.pleaseSelectWereda,
          isWaring: true);
      return;
    }

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
      'subcity': selectedSubCity,
      'wereda': selectedWereda,
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
              margin: const EdgeInsets.only(top: 48, left: 16, right: 16),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                        '${ApiService.API_URL_FILE}${widget.technician.profileImage}'), // replace with actual image source
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.technician.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.service.name,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 10),
                  // Address Selector
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
                    height: 16,
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

                  // Job Description
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: jobDescriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!
                            .describeJobTask, // 'Describe Job Task',

                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
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
                right: 16,
                top: 48,
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close)))
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
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 10),
              Text(AppLocalizations.of(context)!.bookingConfirmed),
            ],
          ),
          content: Text(AppLocalizations.of(context)!.bookingSuccess),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.green)),
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

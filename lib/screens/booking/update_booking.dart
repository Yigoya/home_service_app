import 'package:flutter/material.dart';
import 'package:home_service_app/models/booking.dart';
import 'package:home_service_app/provider/booking_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UpdateBookingPage extends StatefulWidget {
  final Booking booking;

  const UpdateBookingPage({
    super.key,
    required this.booking,
  });

  @override
  _UpdateBookingPageState createState() => _UpdateBookingPageState();
}

class _UpdateBookingPageState extends State<UpdateBookingPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dateController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _subcityController;
  late TextEditingController _weredaController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _zipCodeController;

  @override
  void initState() {
    super.initState();

    _dateController = TextEditingController(text: widget.booking.scheduledDate);
    _streetController =
        TextEditingController(text: widget.booking.address.street);
    _cityController = TextEditingController(text: widget.booking.address.city);
    _subcityController =
        TextEditingController(text: widget.booking.address.subcity);
    _weredaController =
        TextEditingController(text: widget.booking.address.wereda);
    _stateController =
        TextEditingController(text: widget.booking.address.state);
    _countryController =
        TextEditingController(text: widget.booking.address.country);
    _zipCodeController =
        TextEditingController(text: widget.booking.address.zipCode);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _subcityController.dispose();
    _weredaController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = widget.booking.scheduledDate.isNotEmpty
        ? DateFormat('yyyy-MM-ddTHH:mm:ss').parse(widget.booking.scheduledDate)
        : DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text =
            DateFormat('yyyy-MM-ddTHH:mm:ss').format(pickedDate);
      });
    }
  }

  void _saveBooking() {
    if (_formKey.currentState!.validate()) {
      Provider.of<BookingProvider>(context, listen: false)
          .updateBooking(widget.booking.id, {
        "scheduledDate": _dateController.text,
        "street": _streetController.text,
        "city": _cityController.text,
        "subcity": _subcityController.text,
        "wereda": _weredaController.text,
        "state": _stateController.text,
        "country": _countryController.text,
        "zipCode": _zipCodeController.text,
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Booking Saved')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Booking')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: "Scheduled Date",
                  border: OutlineInputBorder(),
                ),
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
                readOnly: true,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: "City",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _subcityController,
                decoration: InputDecoration(
                  labelText: "Subcity",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _weredaController,
                decoration: InputDecoration(
                  labelText: "Wereda",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _stateController,
                decoration: InputDecoration(
                  labelText: "State",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _countryController,
                decoration: InputDecoration(
                  labelText: "Country",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a country';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _zipCodeController,
                decoration: InputDecoration(
                  labelText: "Zip Code",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: _saveBooking,
                child: const Text('Save Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

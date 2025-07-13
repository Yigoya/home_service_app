import 'package:flutter/material.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/provider/booking_provider.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/screens/home/technician_filter.dart';
import 'package:home_service_app/utils/functions.dart';
import 'package:home_service_app/widgets/custom_dropdown.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:home_service_app/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuestionnairePage extends StatefulWidget {
  final Service service;
  const QuestionnairePage({super.key, required this.service});

  @override
  _QuestionnairePageState createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? selectedSubCity;
  String? selectedWereda;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = Provider.of<HomeServiceProvider>(context, listen: false)
          .selectedLocation;

      setState(() {
        selectedSubCity =
            '${Provider.of<HomeServiceProvider>(context, listen: false).subCityNameInLanguage(location, Localizations.localeOf(context))}';
      });
    });
  }

  void _nextPage() {
    if (_selectedDate == null || _selectedTime == null) {
      showTopMessage(
          context, AppLocalizations.of(context)!.pleaseSelectDateAndTime,
          isSuccess: false);
      return;
    }

    if (_currentIndex <
        Provider.of<HomeServiceProvider>(context, listen: false)
                .questions
                .length +
            1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitAnswers();
    }
  }

  void _previeusPage() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitAnswers() {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    final DateTime? fullDateTime =
        _selectedDate != null && _selectedTime != null
            ? DateTime(
                _selectedDate!.year,
                _selectedDate!.month,
                _selectedDate!.day,
                _selectedTime!.hour,
                _selectedTime!.minute,
              )
            : null;

    print({
      "scheduleDateTime": fullDateTime?.toIso8601String(),
      "answers": provider.answers,
    });
    Provider.of<HomeServiceProvider>(context, listen: false)
        .searchTechniciansWithSchedule(
      id: widget.service.id,
      date: _selectedDate!.toLocal().toString().split(' ')[0],
      time:
          "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}",
    );
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => TechnicianFilter(
                  service: widget.service,
                  selectedDate: _selectedDate,
                  selectedTime: _selectedTime,
                )));
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final provider = Provider.of<BookingProvider>(context, listen: false);
      setState(() {
        _selectedDate = pickedDate;
        provider.setSelectedDate(pickedDate);
      });
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final provider = Provider.of<BookingProvider>(context, listen: false);
      setState(() {
        _selectedTime = pickedTime;
        provider.setSelectedTime(pickedTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = Provider.of<HomeServiceProvider>(context).questions;
    double height = 300.h;
    if (_currentIndex == 0) {
      height = 250.h;
    } else if (_currentIndex == 1) {
      height = 250.h;
    } else if (questions[_currentIndex - 2]['type'] == 'INPUT') {
      height = 200.h;
    } else if (questions[_currentIndex - 2]['type'] == 'MULTIPLE_CHOICE') {
      height = 300.h;
    }
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[300]!,
                blurRadius: 10.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 8.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Container(
                  height: 8.h,
                  width: (MediaQuery.of(context).size.width /
                          (questions.length + 1)) *
                      _currentIndex,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(
                height: height,
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      questions.length + 2, // +1 for scheduling date/time page
                  itemBuilder: (context, index) {
                    Logger().d("Index: ${questions.length + 2}");
                    if (index == 0) {
                      return _buildSchedulingPage(context);
                    }
                    if (index == 1) {
                      return _buildLocationPage(context);
                    }
                    final question =
                        questions[index - 2]; // Adjust index for questions
                    return _buildQuestion(context, question);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                      onTap: _previeusPage,
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 48.w, vertical: 8.h),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!)),
                          child: Text(AppLocalizations.of(context)!.back,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600)))),
                  GestureDetector(
                      onTap: _nextPage,
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 48.w, vertical: 8.h),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey[300]!),
                              color: Colors.blue),
                          child: Text(
                            _currentIndex == questions.length + 1
                                ? AppLocalizations.of(context)!.submit
                                : AppLocalizations.of(context)!.next,
                            style:
                                TextStyle(color: Colors.white, fontSize: 14.sp),
                          ))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchedulingPage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 36.h,
        ),
        Text(
          AppLocalizations.of(context)!.selectSchedulingDateAndTime,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 20.h),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 64.w, vertical: 12.h),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey)),
                child: Text(
                  _selectedDate != null
                      ? "${AppLocalizations.of(context)!.date}: ${_selectedDate!.toLocal().toString().split(' ')[0]}"
                      : AppLocalizations.of(context)!.chooseDate,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16.sp,
                      color:
                          _selectedDate == null ? Colors.grey : Colors.black),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: _selectTime,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 64.w, vertical: 12.h),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey)),
                child: Text(
                  _selectedTime != null
                      ? "${AppLocalizations.of(context)!.time}: ${_selectedTime!.format(context)}"
                      : AppLocalizations.of(context)!.chooseTime,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16.sp,
                      color:
                          _selectedDate == null ? Colors.grey : Colors.black),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        if (_selectedDate != null && _selectedTime != null)
          Text(
            "${AppLocalizations.of(context)!.selected}: ${_selectedDate!.toLocal().toString().split(' ')[0]} at ${_selectedTime!.format(context)}",
            style: TextStyle(fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _buildLocationPage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 36.h,
        ),
        Text(
          "Select your location",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 20.h),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomDropdown(
              items: Provider.of<HomeServiceProvider>(context, listen: false)
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
              height: 8.h,
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
          ],
        ),
      ],
    );
  }

  Widget _buildQuestion(BuildContext context, Map<String, dynamic> question) {
    if (question['type'] == 'INPUT') {
      return _buildTextInput(context, question);
    } else if (question['type'] == 'MULTIPLE_CHOICE') {
      return _buildMultipleChoice(context, question);
    }
    return const SizedBox.shrink();
  }

  Widget _buildTextInput(BuildContext context, Map<String, dynamic> question) {
    final provider = Provider.of<BookingProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 36.h,
        ),
        Text(
          question['text'],
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20.h),
        TextField(
          onChanged: (value) {
            provider.updateAnswer(question['id'], value);
          },
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.enterYourAnswerHere,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoice(
      BuildContext context, Map<String, dynamic> question) {
    final provider = Provider.of<BookingProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 36.h,
        ),
        Text(
          question['text'],
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20.h),
        ...question['options'].map<Widget>((option) {
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.only(left: 16.w),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r), border: Border.all()),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(option['optionText']),
                Radio<String>(
                  value: option['optionText'],
                  groupValue: provider.answers[question['id']],
                  onChanged: (value) {
                    provider.updateAnswer(question['id'], value!);
                  },
                )
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

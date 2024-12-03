import 'package:flutter/material.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/provider/booking_provider.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/screens/home/technician_filter.dart';
import 'package:home_service_app/utils/functions.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  // final List<Map<String, dynamic>> _questions = [
  //   {
  //     "id": 1,
  //     "text": "What is your preferred service time?",
  //     "type": "MULTIPLE_CHOICE",
  //     "options": [
  //       {"optionId": 1, "optionText": "Morning"},
  //       {"optionId": 2, "optionText": "Afternoon"},
  //       {"optionId": 3, "optionText": "Evening"}
  //     ],
  //   },
  //   {
  //     "id": 2,
  //     "text": "Tell About Yourself?",
  //     "type": "INPUT",
  //     "options": [],
  //   },
  // ];

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
            .length) {
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

  Future<void> _selectDate(BuildContext context) async {
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

  Future<void> _selectTime(BuildContext context) async {
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
    double height = 300;
    if (_currentIndex == 0) {
      height = 250;
    } else if (questions[_currentIndex - 1]['type'] == 'INPUT') {
      height = 200;
    } else if (questions[_currentIndex - 1]['type'] == 'MULTIPLE_CHOICE') {
      height = 300;
    }
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[300]!,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  height: 8,
                  width: (MediaQuery.of(context).size.width /
                          (questions.length + 1)) *
                      _currentIndex,
                  // width: (_questions.length + 1) / 5 * 20,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(
                height: height,
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      questions.length + 1, // +1 for scheduling date/time page
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildSchedulingPage(context);
                    }
                    final question =
                        questions[index - 1]; // Adjust index for questions
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 48, vertical: 8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!)),
                          child: Text(AppLocalizations.of(context)!.back,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)))),
                  GestureDetector(
                      onTap: _nextPage,
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 48, vertical: 8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                              color: Colors.blue),
                          child: Text(
                            _currentIndex == questions.length
                                ? AppLocalizations.of(context)!.submit
                                : AppLocalizations.of(context)!.next,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
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
        const SizedBox(
          height: 36,
        ),
        Text(
          AppLocalizations.of(context)!.selectSchedulingDateAndTime,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 64, vertical: 12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey)),
                child: Text(
                  _selectedDate != null
                      ? "${AppLocalizations.of(context)!.date}: ${_selectedDate!.toLocal().toString().split(' ')[0]}"
                      : AppLocalizations.of(context)!.chooseDate,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      color:
                          _selectedDate == null ? Colors.grey : Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 64, vertical: 12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey)),
                child: Text(
                  _selectedTime != null
                      ? "${AppLocalizations.of(context)!.time}: ${_selectedTime!.format(context)}"
                      : AppLocalizations.of(context)!.chooseTime,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      color:
                          _selectedDate == null ? Colors.grey : Colors.black),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_selectedDate != null && _selectedTime != null)
          Text(
            "${AppLocalizations.of(context)!.selected}: ${_selectedDate!.toLocal().toString().split(' ')[0]} at ${_selectedTime!.format(context)}",
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
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
        const SizedBox(
          height: 36,
        ),
        Text(
          question['text'],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
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
        const SizedBox(
          height: 36,
        ),
        Text(
          question['text'],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ...question['options'].map<Widget>((option) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), border: Border.all()),
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

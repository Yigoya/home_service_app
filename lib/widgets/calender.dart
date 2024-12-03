import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Calender extends StatefulWidget {
  final List<Map<String, dynamic>>? calender;

  const Calender({super.key, this.calender});
  @override
  _CalenderState createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final calender = widget.calender;
    Logger().d(calender);
    if (calender != null) {
      setState(() {
        _appointments = calender.map((event) {
          return Appointment(
            subject: event['title'],
            startTime: DateTime.parse(event['start']),
            endTime: DateTime.parse(event['end']),
            location: event['location'] ?? 'N/A', // Optional location field
            notes: event['description'] ??
                'No description provided', // Optional description
            color: Colors.blue, // Customize event color
          );
        }).toList();
      });
    } else {
      // Handle API error
      print('Failed to load events');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfCalendar(
      view: CalendarView.month,
      dataSource: AppointmentDataSource(_appointments),
      onTap: (CalendarTapDetails details) {
        if (details.appointments != null && details.appointments!.isNotEmpty) {
          final Appointment appointment = details.appointments!.first;
          _showEventDetails(context, appointment);
        }
      },
      todayHighlightColor: Colors.red,
    );
  }

  void _showEventDetails(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appointment.subject),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Start: ${appointment.startTime}"),
              Text("End: ${appointment.endTime}"),
              Text("Location: ${appointment.location}"),
              Text("Description: ${appointment.notes}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}

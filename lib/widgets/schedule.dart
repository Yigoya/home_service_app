import 'package:flutter/material.dart';
import 'package:home_service_app/models/schedule.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScheduleWidget extends StatefulWidget {
  final Schedule schedule;
  final Function(Schedule) onSave;

  const ScheduleWidget(
      {super.key, required this.schedule, required this.onSave});

  @override
  _ScheduleWidgetState createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> {
  final DateFormat timeFormat = DateFormat("HH:mm:ss");
  bool isChanged = false;
  Future<void> _pickTime(String day, bool isStart) async {
    final initialTime = TimeOfDay.now();
    final selectedTime =
        await showTimePicker(context: context, initialTime: initialTime);
    if (selectedTime != null) {
      final parsedTime = timeFormat
          .format(DateTime(0, 0, 0, selectedTime.hour, selectedTime.minute));
      setState(() {
        _updateSchedule(day, isStart, parsedTime);
      });
    }
  }

  void _updateSchedule(String day, bool isStart, String time) {
    switch (day) {
      case "Monday":
        isStart
            ? widget.schedule.mondayStart = time
            : widget.schedule.mondayEnd = time;
        break;
      case "Tuesday":
        isStart
            ? widget.schedule.tuesdayStart = time
            : widget.schedule.tuesdayEnd = time;
        break;
      case "Wednesday":
        isStart
            ? widget.schedule.wednesdayStart = time
            : widget.schedule.wednesdayEnd = time;
        break;
      case "Thursday":
        isStart
            ? widget.schedule.thursdayStart = time
            : widget.schedule.thursdayEnd = time;
        break;
      case "Friday":
        isStart
            ? widget.schedule.fridayStart = time
            : widget.schedule.fridayEnd = time;
        break;
      case "Saturday":
        isStart
            ? widget.schedule.saturdayStart = time
            : widget.schedule.saturdayEnd = time;
        break;
      case "Sunday":
        isStart
            ? widget.schedule.sundayStart = time
            : widget.schedule.sundayEnd = time;
        break;
    }
    setState(() {
      isChanged = true;
    });
  }

  Widget _buildDayScheduleRow(String day, String start, String end) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
        TextButton(
          onPressed: () => _pickTime(day, true),
          child: Text(start.isEmpty ? "Start Time" : start),
        ),
        TextButton(
          onPressed: () => _pickTime(day, false),
          child: Text(end.isEmpty ? "End Time" : end),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0.w),
      child: Column(
        children: [
          _buildDayScheduleRow("Monday", widget.schedule.mondayStart ?? "",
              widget.schedule.mondayEnd ?? ""),
          _buildDayScheduleRow("Tuesday", widget.schedule.tuesdayStart ?? "",
              widget.schedule.tuesdayEnd ?? ""),
          _buildDayScheduleRow(
              "Wednesday",
              widget.schedule.wednesdayStart ?? "",
              widget.schedule.wednesdayEnd ?? ""),
          _buildDayScheduleRow("Thursday", widget.schedule.thursdayStart ?? "",
              widget.schedule.thursdayEnd ?? ""),
          _buildDayScheduleRow("Friday", widget.schedule.fridayStart ?? "",
              widget.schedule.fridayEnd ?? ""),
          _buildDayScheduleRow("Saturday", widget.schedule.saturdayStart ?? "",
              widget.schedule.saturdayEnd ?? ""),
          _buildDayScheduleRow("Sunday", widget.schedule.sundayStart ?? "",
              widget.schedule.sundayEnd ?? ""),
          isChanged
              ? ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isChanged = false;
                    });
                    widget.onSave(widget.schedule);
                  },
                  child: const Text("Save"))
              : const SizedBox.shrink()
        ],
      ),
    );
  }
}

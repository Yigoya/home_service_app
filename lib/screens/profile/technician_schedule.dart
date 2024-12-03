import 'package:flutter/material.dart';
import 'package:home_service_app/models/schedule.dart';
import 'package:home_service_app/provider/profile_page_provider.dart';
import 'package:home_service_app/widgets/calender.dart';
import 'package:home_service_app/widgets/schedule.dart';
import 'package:provider/provider.dart';

class TechnicianSchedule extends StatefulWidget {
  const TechnicianSchedule({super.key});

  @override
  State<TechnicianSchedule> createState() => _TechnicianScheduleState();
}

class _TechnicianScheduleState extends State<TechnicianSchedule> {
  void saveSchedule(Schedule schedule) {
    Provider.of<ProfilePageProvider>(context, listen: false)
        .setSchedule(schedule);
    print("Schedule saved: $schedule");
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfilePageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
      ),
      body: Column(
        children: [
          Calender(
            calender: provider.calender,
          ),
          ScheduleWidget(
            schedule: provider.schedule,
            onSave: saveSchedule,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DisputeListPage extends StatelessWidget {
  const DisputeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disputes You Submitted')),
      body: Consumer<UserProvider>(
        builder: (context, disputeProvider, child) {
          if (disputeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (disputeProvider.disputes.isEmpty) {
            return Center(
              child: Text(
                  'You have not submitted any disputes.\n If you have any issues, please submit a dispute.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  )),
            );
          }
          return ListView.builder(
            itemCount: disputeProvider.disputes.length,
            itemBuilder: (context, index) {
              final dispute = disputeProvider.disputes[index];
              return Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 8.0.h, horizontal: 16.0.w),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16.0.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dispute.reason,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.sp),
                        ),
                        SizedBox(height: 5.h),
                        Text(dispute.description,
                            style: TextStyle(fontSize: 14.sp)),
                        SizedBox(height: 10.h),
                        GestureDetector(
                          onTap: () {
                            // disputeProvider.removeDispute(index);
                          },
                          child: Text(
                            'close',
                            style:
                                TextStyle(color: Colors.blue, fontSize: 14.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

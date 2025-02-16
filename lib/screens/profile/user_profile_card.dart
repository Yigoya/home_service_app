import 'package:flutter/material.dart';
import 'package:home_service_app/models/user.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/profile/technician_schedule.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/widgets/language_selector.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserProfileComponent extends StatelessWidget {
  final User user;
  final Function onImagePick;
  final Function onEditName;

  const UserProfileComponent({
    super.key,
    required this.user,
    required this.onImagePick,
    required this.onEditName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundImage: user.profileImage != null
                        ? NetworkImage(
                            '${ApiService.API_URL}/uploads/${user.profileImage}')
                        : const AssetImage('assets/images/profile.png')
                            as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        onImagePick();
                      },
                      child: CircleAvatar(
                        radius: 16.r,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16.w),
              Padding(
                padding: EdgeInsets.all(16.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(user.name,
                            style: TextStyle(
                                fontSize: 20.sp, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8.w),
                        IconButton(
                          icon: Icon(Icons.edit, size: 20.sp),
                          onPressed: () {
                            onEditName(context, user);
                          },
                        ),
                      ],
                    ),
                    Text(user.email, style: TextStyle(fontSize: 14.sp)),
                    Text(user.phoneNumber, style: TextStyle(fontSize: 14.sp)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const LanguageSelector(),
              if (user.role == "TECHNICIAN")
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TechnicianSchedule()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(AppLocalizations.of(context)!.seeMySchedule,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color.fromARGB(255, 16, 77, 128),
                        )),
                  ),
                ),
              GestureDetector(
                  onTap: () async {
                    await Provider.of<UserProvider>(context, listen: false)
                        .clearUser();
                    Navigator.of(context, rootNavigator: true)
                        .pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text('Logout',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color.fromARGB(255, 92, 19, 14),
                        )),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

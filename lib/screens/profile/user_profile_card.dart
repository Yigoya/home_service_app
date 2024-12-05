import 'package:flutter/material.dart';
import 'package:home_service_app/models/user.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/profile/technician_schedule.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/widgets/language_selector.dart';
import 'package:provider/provider.dart';

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
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
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
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(user.name,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () {
                            onEditName(context, user);
                          },
                        ),
                      ],
                    ),
                    Text(user.email),
                    Text(user.phoneNumber),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (user.role == "TECHNICIAN")
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const LanguageSelector(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TechnicianSchedule()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('See my Schedule',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 16, 77, 128),
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Logout',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 92, 19, 14),
                          )),
                    )),
              ],
            ),
        ],
      ),
    );
  }
}

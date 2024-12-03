import 'package:flutter/material.dart';
import 'package:home_service_app/models/user.dart';
import 'package:home_service_app/services/api_service.dart';

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
      child: Row(
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
    );
  }
}

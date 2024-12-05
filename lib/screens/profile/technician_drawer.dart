import 'package:flutter/material.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/profile/technician_schedule.dart';
import 'package:provider/provider.dart';
// Adjust the import according to your project structure

class TechnicianDrawer extends StatelessWidget {
  const TechnicianDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const UserAccountsDrawerHeader(
            accountName: Text('John Doe'),
            accountEmail: Text('john.doe@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage(
                  'assets/profile_picture.png'), // Add a profile picture
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to settings page
            },
          ),
        ],
      ),
    );
  }
}

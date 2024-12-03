import 'package:flutter/material.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:provider/provider.dart';

class HomePageCopy extends StatelessWidget {
  const HomePageCopy({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await userProvider.clearUser();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
      body: user != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Welcome, ${user.name}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  UserInfoTile(title: 'Email', value: user.email),
                  UserInfoTile(title: 'Phone Number', value: user.phoneNumber),
                  UserInfoTile(title: 'Role', value: user.role),
                  UserInfoTile(title: 'Status', value: user.status),
                ],
              ),
            )
          : const Center(child: Text('No user data found')),
    );
  }
}

class UserInfoTile extends StatelessWidget {
  final String title;
  final String value;

  const UserInfoTile({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}

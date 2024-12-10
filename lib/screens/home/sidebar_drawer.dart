import 'package:flutter/material.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/utils/route_generator.dart';
import 'package:provider/provider.dart';

class SideNavDrawer extends StatelessWidget {
  const SideNavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.home_repair_service,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(width: 10),
                Text(
                  "Home Service",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // List of Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.contact_mail,
                  label: 'Contact',
                  onTap: () {
                    Navigator.of(context, rootNavigator: true)
                        .pushNamed(RouteGenerator.contactPage);
                  },
                ),
                _buildNavItem(
                  context,
                  icon: Icons.report_problem,
                  label: 'Dispute',
                  onTap: () {
                    Provider.of<UserProvider>(context, listen: false)
                        .fetchDispute();
                    Navigator.of(context, rootNavigator: true)
                        .pushNamed(RouteGenerator.disputeListPage);
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.grey[600]),
            title: Text(
              'Log Out',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            onTap: () async {
              await Provider.of<UserProvider>(context, listen: false)
                  .clearUser();
              Navigator.of(context, rootNavigator: true)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  // Helper widget for building each navigation item
  Widget _buildNavItem(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}

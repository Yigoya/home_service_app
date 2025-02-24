import 'package:flutter/material.dart';
import 'package:home_service_app/models/login_source.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/auth/login.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TenderDrawer extends StatefulWidget {
  const TenderDrawer({super.key});

  @override
  State<TenderDrawer> createState() => _TenderDrawerState();
}

class _TenderDrawerState extends State<TenderDrawer> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          user == null
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 42, bottom: 12),
                  color: Theme.of(context).secondaryHeaderColor,
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 40,
                        child: Icon(Icons.person_outline,
                            size: 40,
                            color: Theme.of(context).secondaryHeaderColor),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Guest User",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Please log in",
                        style: TextStyle(fontSize: 14, color: Colors.white54),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                )
              : UserAccountsDrawerHeader(
                  accountName: Text(user.name),
                  accountEmail: Text(user.email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        size: 40,
                        color: Theme.of(context).secondaryHeaderColor),
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
          _buildDrawerItem(
              icon: Icons.login,
              text: "Login",
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginPage(
                            source: LoginSource.tender,
                          )))),
          _buildDrawerItem(
              icon: Icons.subscriptions,
              text: "Subscription",
              onTap: () => _navigate(context, "/subscription")),
          _buildDrawerItem(
              icon: Icons.notifications,
              text: "Notification",
              onTap: () => _navigate(context, "/notification")),
          _buildDrawerItem(
              icon: Icons.language,
              text: "Visit website",
              onTap: () => _launchURL("https://yigoya.github.io/servicelink/")),
          _buildDrawerItem(
              icon: Icons.info,
              text: "About us",
              onTap: () => _navigate(context, "/about")),
          _buildDrawerItem(
              icon: Icons.contact_page,
              text: "Contact us",
              onTap: () => _navigate(context, "/contact")),
          const Spacer(), // Push logout button to bottom
          const Divider(),
          _buildDrawerItem(
              icon: Icons.logout,
              text: "Log out",
              color: Colors.red,
              onTap: () => _logout(context)),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon,
      required String text,
      required VoidCallback onTap,
      Color? color}) {
    return ListTile(
      leading:
          Icon(icon, color: color ?? Theme.of(context).secondaryHeaderColor),
      title: Text(text,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.black)),
      onTap: onTap,
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context); // Close drawer
    Navigator.pushNamed(context, route);
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      debugPrint("Could not launch $url");
    }
  }

  void _logout(BuildContext context) {
    // Add logout logic here
    Navigator.pop(context);
    debugPrint("User logged out");
  }
}

import 'package:flutter/material.dart';
import 'package:luxe_nail/screens/dashboard_screen.dart';
import 'package:luxe_nail/screens/login_screen.dart';

class DesignDrawer extends StatelessWidget {
  final String token;
  final Map<String, dynamic> user;
  final double Function(num) sW;

  const DesignDrawer({
    super.key,
    required this.token,
    required this.user,
    required this.sW,
  });

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback tap,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF451A2B)),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF451A2B),
          fontFamily: "Poppins",
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: tap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFFF8F9),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFAF7C85)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: sW(30),
                  backgroundColor: const Color(0xFFFFEAEE),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Color(0xFF451A2B),
                  ),
                ),
                SizedBox(height: sW(10)),
                Text(
                  'Welcome, ${user['name']}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(context, Icons.home, "Home", () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => DashboardScreen(token: token, user: user),
              ),
            );
          }),
          _drawerItem(context, Icons.brush, "Jenis Treatment", () {
            Navigator.pop(context);
          }),
          const Divider(color: Color(0xFFAF7C85)),
          _drawerItem(context, Icons.logout, "Logout", () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }),
        ],
      ),
    );
  }
}

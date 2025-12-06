import 'package:flutter/material.dart';
import 'package:luxe_nail/screens/dashboard_screen.dart';
import 'package:luxe_nail/screens/history_screen.dart';
import 'package:luxe_nail/screens/profile_screen.dart';
import 'package:luxe_nail/screens/login_screen.dart';

class GalleryDrawer extends StatelessWidget {
  final String token;
  final Map<String, dynamic> user;

  const GalleryDrawer({
    super.key,
    required this.token,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFFF8F9),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFAF7C85), Color(0xFF975B73)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFFFEAEE),
                  child: Icon(Icons.person, size: 40, color: Color(0xFF451A2B)),
                ),
                const SizedBox(height: 12),
                Text('Welcome,',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14)),
                Text(user['username'] ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_rounded, color: Color(0xFF451A2B)),
            title: const Text("Home",
                style:
                    TextStyle(fontFamily: 'Poppins', color: Color(0xFF451A2B))),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          DashboardScreen(token: token, user: user)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded,
                color: Color(0xFFAF7C85)),
            title: const Text("Catalog",
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFFAF7C85),
                    fontWeight: FontWeight.w600)),
            tileColor: const Color(0xFFFFEAEE),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading:
                const Icon(Icons.history_rounded, color: Color(0xFF451A2B)),
            title: const Text("History",
                style:
                    TextStyle(fontFamily: 'Poppins', color: Color(0xFF451A2B))),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => HistoryScreen(token: token, user: user)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_rounded, color: Color(0xFF451A2B)),
            title: const Text("Profile",
                style:
                    TextStyle(fontFamily: 'Poppins', color: Color(0xFF451A2B))),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProfileScreen(token: token, user: user)));
            },
          ),
          const Divider(color: Color(0xFFE5C1C8), thickness: 1),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Color(0xFF975B73)),
            title: const Text("Logout",
                style:
                    TextStyle(fontFamily: 'Poppins', color: Color(0xFF975B73))),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false);
            },
          ),
        ],
      ),
    );
  }
}

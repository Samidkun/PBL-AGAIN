import 'package:flutter/material.dart';
import 'package:luxe_nail/screens/login_screen.dart';
import 'package:luxe_nail/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final String token;
  const ProfileScreen({super.key, required this.token});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  bool _isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final result = await ApiService.getUserProfile(widget.token);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success']) {
        user = result['data'];
      } else {
        errorMessage = result['message'];
        if (result['statusCode'] == 401) {
          errorMessage = 'Session expired. Please log in again.';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEAEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEF909D),
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFEF909D)),
            )
          : errorMessage != null
          ? Center(
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // ✅ FIX 2A: Agar semua konten mengikuti perataan tengah
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFEF909D),
                  child: Icon(Icons.person, color: Colors.white, size: 60),
                ),
                const SizedBox(height: 20),
                // ✅ FIX 2B: Membungkus Text dengan Center agar benar-benar rata tengah
                Center( 
                  child: Text(
                    user?['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color(0xFF451A2B),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // ✅ FIX 2B: Membungkus Text dengan Center
                Center( 
                  child: Text(
                    user?['role'] ?? '-',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF451A2B),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // ✅ FIX 2B: Membungkus Text dengan Center
                Center( 
                  child: Text(
                    user?['email'] ?? '-',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF451A2B),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF909D),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
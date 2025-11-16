import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:luxe_nail/screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://192.168.1.67:8000';
      final url = Uri.parse('$baseUrl/api/user');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
          // ✅ FIX 1: Menghindari Ngrok warning page (HTML)
          'ngrok-skip-browser-warning': 'true', 
        },
      );

      if (response.statusCode == 200) {
        // Cek jika response body kosong (meskipun status 200)
        if (response.body.isNotEmpty) {
           final data = jsonDecode(response.body);
            setState(() {
              user = data;
              _isLoading = false;
            });
        } else {
            // Menangani kasus 200 OK tapi tanpa body (jarang terjadi di API)
            setState(() {
              errorMessage = 'Failed to load profile. Empty response body.';
              _isLoading = false;
            });
        }

      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Session expired. Please log in again.';
          _isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load profile. [${response.statusCode}] ${response.reasonPhrase}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Unexpected error: $e';
        _isLoading = false;
      });
    }
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
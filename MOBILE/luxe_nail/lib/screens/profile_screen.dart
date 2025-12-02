import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:luxe_nail/screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:luxe_nail/screens/ai_screen.dart';
import 'package:luxe_nail/screens/gallery_screen.dart';

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
      final url = Uri.parse('$baseUrl/api/v1/user');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);
          setState(() {
            user = data;
            _isLoading = false;
          });
        } else {
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

// ================================================================
// BOTTOM NAVBAR (VERSI BISA DIKLIK)
// ================================================================
  Widget _bottomNavbar(BuildContext context) {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(27),
          topRight: Radius.circular(27),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 9,
            offset: Offset(5, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // HOME -> balik ke halaman sebelumnya (biasanya Dashboard)
          _navItem(Icons.home, "Home", () {
            Navigator.pop(context);
          }),

          // AI -> kirim token + user yg baru saja di-fetch di Profile
          _navItem(Icons.auto_awesome, "AI", () {
            if (user == null) return; // jaga2 kalau datanya belum ke-load
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AIScreen(
                  token: widget.token,
                  user: user!, // <-- pakai variabel user di Profile
                  reservation: null,
                ),
              ),
            );
          }),

          // GALLERY
          _navItem(Icons.photo_album, "Gallery", () {
            if (user == null) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GalleryScreen(
                  token: widget.token,
                  user: user!,
                ),
              ),
            );
          }),

          // PROFILE -> lagi di halaman ini, jadi nggak perlu ngapa2in
          _navItem(Icons.person, "Profile", () {
            // bisa dikosongin atau Navigator.popUntil kalau mau
          }),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 30,
            color: const Color(0xFF975B73),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: Color(0xFFCEA8BC),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEE9CA7),
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFEE9CA7),
                strokeWidth: 3,
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.red.shade300,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red.shade400,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // ---------------------------
                      // Profile Header Card
                      // ---------------------------
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFEE9CA7),
                              Color(0xFFF3B8C2),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD87A87)
                                  .withValues(alpha: 0.25),
                              blurRadius: 40,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Avatar
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 5,
                                    ),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFFFECD2),
                                        Color(0xFFFCB69F),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF451A2B)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      (user?['name'] ?? 'U')
                                          .toString()
                                          .substring(0, 2)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 5,
                                  right: 5,
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.15),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Color(0xFFEE9CA7),
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Name
                            Text(
                              user?['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 24,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Role
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.shield_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  user?['role'] ?? 'Administrator',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Active Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF4ADE80),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Active',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ---------------------------
                      // Account Information Card
                      // ---------------------------
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD87A87)
                                    .withValues(alpha: 0.15),
                                blurRadius: 40,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.account_circle,
                                    color: Color(0xFFEE9CA7),
                                    size: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Account Information",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF451A2B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildInfoRow("Email", user?['email'] ?? "-"),
                              const SizedBox(height: 16),
                              _buildInfoRow("Role", user?['role'] ?? "-"),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ---------------------------
                      // Logout Button
                      // ---------------------------
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFEE9CA7),
                                  Color(0xFFD87A87),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEE9CA7)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
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
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.logout_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Logout",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 110), // Extra space untuk navbar
                    ],
                  ),
                ),
      bottomNavigationBar: _bottomNavbar(context),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF8B4A5A),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            border: Border.all(
              color: const Color(0xFFF3B8C2),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: Color(0xFF451A2B),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:luxe_nail/screens/dashboard_screen.dart';
import 'package:luxe_nail/screens/design_screen.dart';
import 'package:luxe_nail/screens/gallery_screen.dart';
import 'package:luxe_nail/screens/profile_screen.dart';
import 'package:luxe_nail/utils/responsive.dart';

import 'login_screen.dart';

class JenisTreatmentScreen extends StatelessWidget {
  JenisTreatmentScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFFEAEE),

      drawer: _buildDrawer(context),

      body: Stack(
        children: [
          // ================= HEADER =================
          Positioned(
            left: Responsive.sW(context, 26),
            top: Responsive.sH(context, 60),
            child: SizedBox(
              width: Responsive.sW(context, 351),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _scaffoldKey.currentState!.openDrawer(),
                    child: Icon(
                      Icons.menu,
                      size: Responsive.sW(context, 32),
                      color: const Color(0xFF451A2B),
                    ),
                  ),
                  Text(
                    'LUXE NAIL',
                    style: TextStyle(
                      color: const Color(0xFF975B73),
                      fontSize: Responsive.sW(context, 20),
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= MAIN CONTAINER =================
          Positioned(
            left: Responsive.sW(context, 13),
            top: Responsive.sH(context, 140),
            child: Container(
              width: Responsive.sW(context, 386),
              height: Responsive.sH(context, 720),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Responsive.sW(context, 30)),
                    topRight: Radius.circular(Responsive.sW(context, 30)),
                  ),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: Responsive.sW(context, -10),
                    top: Responsive.sH(context, -10),
                    child: Opacity(
                      opacity: 0.5,
                      child: Image.asset(
                        "assets/images/Splas1-HAND.png",
                        width: Responsive.sW(context, 386),
                        height: Responsive.sH(context, 720),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Banner
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: Responsive.sH(context, 10)),
                      child: Image.asset(
                        "assets/images/jenis treatment-Vektor Tangan.png",
                        width: Responsive.sW(context, 350),
                        height: Responsive.sH(context, 180),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Title
                  Positioned(
                    top: Responsive.sH(context, 205),
                    left: Responsive.sW(context, 45),
                    child: SizedBox(
                      width: Responsive.sW(context, 300),
                      child: Text(
                        "What would you like to get done today?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF451A2B),
                          fontSize: Responsive.sW(context, 20),
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // CARDS
                  Positioned(
                    top: Responsive.sH(context, 300),
                    left: Responsive.sW(context, 20),
                    child: Wrap(
                      spacing: Responsive.sW(context, 15),
                      children: [
                        _treatmentCard(
                          context: context,
                          img: "assets/images/jenis treatment-Nail Exten.png",
                          title: "Nail Extension",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DesignScreen()),
                          ),
                        ),
                        _treatmentCard(
                          context: context,
                          img: "assets/images/jenis tretment-Nail art.png",
                          title: "Nail Art",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DesignScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= BOTTOM NAVBAR =================
          _buildBottomNavbar(context),
        ],
      ),
    );
  }

  // ================= DRAWER =================
  Widget _buildDrawer(BuildContext context) {
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
                  radius: Responsive.sW(context, 30),
                  backgroundColor: const Color(0xFFFFEAEE),
                  child: Icon(
                    Icons.person,
                    size: Responsive.sW(context, 40),
                    color: const Color(0xFF451A2B),
                  ),
                ),
                SizedBox(height: Responsive.sH(context, 10)),
                const Text(
                  'Welcome Nailist!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF451A2B)),
            title: const Text(
              "Home",
              style: TextStyle(
                color: Color(0xFF451A2B),
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => Navigator.pop(context),
          ),

          ListTile(
            leading: const Icon(Icons.brush, color: Color(0xFF451A2B)),
            title: const Text(
              "Jenis Treatment",
              style: TextStyle(
                color: Color(0xFF451A2B),
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => Navigator.pop(context),
          ),

          const Divider(color: Color(0xFFAF7C85)),

          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFF451A2B)),
            title: const Text(
              "Logout",
              style: TextStyle(color: Color(0xFF451A2B), fontFamily: "Poppins"),
            ),
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            ),
          ),
        ],
      ),
    );
  }

  // ================= TREATMENT CARD =================
  Widget _treatmentCard({
    required BuildContext context,
    required String img,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      width: Responsive.sW(context, 168),
      height: Responsive.sH(context, 300),
      padding: EdgeInsets.all(Responsive.sW(context, 10)),
      decoration: BoxDecoration(
        color: const Color(0xFFAF7C85),
        borderRadius: BorderRadius.circular(Responsive.sW(context, 14)),
      ),
      child: Column(
        children: [
          Container(
            width: Responsive.sW(context, 150),
            height: Responsive.sH(context, 230),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEAEE),
              borderRadius: BorderRadius.circular(Responsive.sW(context, 5)),
            ),
            child: Column(
              children: [
                Container(
                  width: Responsive.sW(context, 148),
                  height: Responsive.sH(context, 185),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(img),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: Responsive.sH(context, 7)),
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF451A2B),
                    fontSize: Responsive.sW(context, 13),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.sH(context, 12)),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.sW(context, 14),
                vertical: Responsive.sH(context, 7),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF451A2B),
                borderRadius: BorderRadius.circular(Responsive.sW(context, 14)),
              ),
              child: Text(
                "Confirm",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.sW(context, 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BOTTOM NAV =================
  Widget _buildBottomNavbar(BuildContext context) {
    return Positioned(
      left: 0,
      top: Responsive.sH(context, 800),
      child: Container(
        width: Responsive.sW(context, 412),
        height: Responsive.sH(context, 120),
        padding: EdgeInsets.only(
          top: Responsive.sH(context, 24),
          left: Responsive.sW(context, 46),
          right: Responsive.sW(context, 46),
          bottom: Responsive.sH(context, 30),
        ),
        decoration: ShapeDecoration(
          color: const Color(0xFFFFF8F9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Responsive.sW(context, 27)),
              topRight: Radius.circular(Responsive.sW(context, 27)),
            ),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 9,
              offset: Offset(5, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _bottomNavItem(
              context,
              label: "Back",
              icon: Icons.arrow_back,
              onTap: () => Navigator.pop(context),
            ),
            _bottomNavItem(
              context,
              label: "Design",
              icon: Icons.brush,
              onTap: () {},
            ),
            _bottomNavItem(
              context,
              label: "Home",
              icon: Icons.home,
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => DashboardScreen()),
                (route) => false,
              ),
            ),
            _bottomNavItem(
              context,
              label: "Gallery",
              icon: Icons.photo_album,
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => GalleryScreen()),
                (route) => false,
              ),
            ),
            _bottomNavItem(
              context,
              label: "Profile",
              icon: Icons.person,
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
                (route) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= NAV ITEM =================
  Widget _bottomNavItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFF975B73),
            size: Responsive.sW(context, 32),
          ),
          SizedBox(height: Responsive.sH(context, 5)),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFCEA8BC),
              fontSize: 11,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

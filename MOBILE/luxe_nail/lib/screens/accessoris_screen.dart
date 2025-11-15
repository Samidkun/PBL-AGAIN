import 'package:flutter/material.dart';
import 'package:luxe_nail/screens/dashboard_screen.dart';
import 'package:luxe_nail/screens/finishing_screen.dart';
import 'package:luxe_nail/screens/gallery_screen.dart';
import 'package:luxe_nail/screens/profile_screen.dart';
import 'package:luxe_nail/utils/responsive.dart';

import 'login_screen.dart';

class AccessorisScreen extends StatelessWidget {
  AccessorisScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final sW = (num v) => Responsive.sW(context, v);
    final sH = (num v) => Responsive.sH(context, v);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFFEAEE),

      // ================= DRAWER =================
      drawer: Drawer(
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
                    child: Icon(
                      Icons.person,
                      size: sW(40),
                      color: const Color(0xFF451A2B),
                    ),
                  ),
                  SizedBox(height: sH(10)),
                  const Text(
                    "Welcome Nailist!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            _drawerItem(Icons.home, "Home", () {
              Navigator.pop(context);
            }),

            _drawerItem(Icons.brush, "Jenis Treatment", () {
              Navigator.pop(context);
            }),

            const Divider(color: Color(0xFFAF7C85)),

            _drawerItem(Icons.logout, "Logout", () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }),
          ],
        ),
      ),

      // ================= BODY =================
      body: Stack(
        children: [
          // ================= HEADER =================
          Positioned(
            left: sW(26),
            top: sH(60),
            child: SizedBox(
              width: sW(351),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _scaffoldKey.currentState!.openDrawer(),
                    child: Icon(
                      Icons.menu,
                      size: sW(32),
                      color: const Color(0xFF451A2B),
                    ),
                  ),
                  Text(
                    "LUXE NAIL",
                    style: TextStyle(
                      color: const Color(0xFF975B73),
                      fontSize: sW(22),
                      fontFamily: "Georgia",
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= MAIN CONTAINER =================
          Positioned(
            left: sW(13),
            top: sH(110),
            child: Container(
              width: sW(386),
              height: sH(720),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(sW(30)),
                  topRight: Radius.circular(sW(30)),
                ),
              ),

              child: Stack(
                children: [
                  // Background
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Opacity(
                      opacity: 0.9,
                      child: Image.asset(
                        "assets/images/Splas1-HAND.png",
                        width: sW(386),
                        height: sH(720),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // ================= MAIN CONTENT =================
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: sW(20),
                      vertical: sH(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Title
                        SizedBox(
                          width: sW(330),
                          child: Text(
                            "Choose Your Accessories Of Nails",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF451A2B),
                              fontSize: sW(20),
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        SizedBox(height: sH(20)),

                        // White shadow box
                        Container(
                          width: sW(330),
                          height: sH(350),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(sW(13)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 6.2,
                                offset: Offset(-2, 6),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: sH(20)),

                        // ================= HORIZONTAL SCROLL CARDS =================
                        SizedBox(
                          height: sH(140),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                accessoryCard(context, "Rp. 20.000", "Flower"),
                                SizedBox(width: sW(12)),
                                accessoryCard(context, "Rp. 20.000", "Pearls"),
                                SizedBox(width: sW(12)),
                                accessoryCard(context, "Rp. 20.000", "Pita"),
                                SizedBox(width: sW(12)),
                                accessoryCard(context, "Rp. 30.000", "Diamond"),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: sH(15)),

                        // Confirm button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FinishingScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: sW(330),
                            padding: EdgeInsets.symmetric(vertical: sH(10)),
                            decoration: BoxDecoration(
                              color: const Color(0xFF451A2B),
                              borderRadius: BorderRadius.circular(sW(14)),
                            ),
                            child: Center(
                              child: Text(
                                "Confirm",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: sW(14),
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
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
          Positioned(
            left: 0,
            top: sH(800),
            child: Container(
              width: sW(412),
              height: sH(120),
              padding: EdgeInsets.only(
                top: sH(24),
                left: sW(46),
                right: sW(46),
                bottom: sH(30),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(sW(27)),
                  topRight: Radius.circular(sW(27)),
                ),
                boxShadow: const [
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
                  _bottomItem(context, "Back", Icons.arrow_back, () {
                    Navigator.pop(context);
                  }),
                  _bottomItem(context, "Design", Icons.brush, () {}),
                  _bottomItem(context, "Home", Icons.home, () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => DashboardScreen()),
                      (route) => false,
                    );
                  }),
                  _bottomItem(context, "Gallery", Icons.photo_album, () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => GalleryScreen()),
                      (route) => false,
                    );
                  }),
                  _bottomItem(context, "Profile", Icons.person, () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileScreen()),
                      (route) => false,
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== Drawer Item ==========
  Widget _drawerItem(IconData icon, String label, VoidCallback tap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF451A2B)),
      title: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF451A2B),
          fontSize: 14,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: tap,
    );
  }

  // ========== Bottom Nav Item ==========
  Widget _bottomItem(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback tap,
  ) {
    return GestureDetector(
      onTap: tap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: Responsive.sW(context, 32),
            color: const Color(0xFF975B73),
          ),
          SizedBox(height: Responsive.sH(context, 5)),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFFCEA8BC),
              fontSize: Responsive.sW(context, 11),
              fontFamily: "Poppins",
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ========== ACCESSORY CARD (RESPONSIVE) ==========
  Widget accessoryCard(BuildContext context, String price, String title) {
    final sW = (num v) => Responsive.sW(context, v);
    final sH = (num v) => Responsive.sH(context, v);

    return Container(
      width: sW(108),
      height: sH(130),
      padding: EdgeInsets.symmetric(horizontal: sW(5), vertical: sH(10)),
      decoration: BoxDecoration(
        color: const Color(0xFFAF7C85),
        borderRadius: BorderRadius.circular(sW(12)),
      ),
      child: Column(
        children: [
          // Price box
          Container(
            width: sW(98),
            height: sH(22),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEAEE),
              borderRadius: BorderRadius.circular(sW(5)),
            ),
            child: Center(
              child: Text(
                price,
                style: TextStyle(
                  color: const Color(0xFF451A2B),
                  fontSize: sW(12),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          SizedBox(height: sH(8)),

          // Title box
          Container(
            width: sW(98),
            height: sH(78),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEAEE),
              borderRadius: BorderRadius.circular(sW(5)),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF451A2B),
                  fontSize: sW(12),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

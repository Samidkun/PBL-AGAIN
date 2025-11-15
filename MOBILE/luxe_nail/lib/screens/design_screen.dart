import 'package:flutter/material.dart';
import 'package:luxe_nail/screens/accessoris_screen.dart';
import 'package:luxe_nail/screens/dashboard_screen.dart';
import 'package:luxe_nail/screens/gallery_screen.dart';
import 'package:luxe_nail/screens/profile_screen.dart';
import 'package:luxe_nail/utils/responsive.dart';

import 'login_screen.dart';

class DesignScreen extends StatelessWidget {
  DesignScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final sW = (num v) => Responsive.sW(context, v);
    final sH = (num v) => Responsive.sH(context, v);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFFEAEE),

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
            _drawerItem(context, Icons.home, "Home", () {
              Navigator.pop(context);
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
      ),

      body: Stack(
        children: [
          // HEADER
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
                      fontSize: sW(20),
                      fontFamily: "Georgia",
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== MAIN CONTENT FIXED (NO OVERFLOW) =====
          Positioned(
            left: sW(13),
            top: sH(140),
            child: Container(
              width: sW(386),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(sW(30)),
                  topRight: Radius.circular(sW(30)),
                ),
              ),

              // FIX: Scroll di container luar
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    // Background transparan
                    Opacity(
                      opacity: 0.9,
                      child: Image.asset(
                        "assets/images/Splas1-HAND.png",
                        width: sW(386),
                        height: sH(1000),
                        fit: BoxFit.cover,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: sW(20),
                        vertical: sH(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _title("Choose Your Category Of Nails", sW),
                          SizedBox(height: sH(10)),
                          _horizontalScroll(sW, sH, [
                            _card(context, "Rp. 20.000", "Coffin"),
                            _card(context, "Rp. 20.000", "Almond"),
                            _card(context, "Rp. 20.000", "Stiletto"),
                            _card(context, "Rp. 25.000", "Round"),
                            _card(context, "Rp. 30.000", "Square"),
                          ]),

                          SizedBox(height: sH(30)),
                          _title("Choose Your Type Of Nails", sW),
                          SizedBox(height: sH(10)),
                          _horizontalScroll(sW, sH, [
                            _card(context, "Rp. 20.000", "Coffin"),
                            _card(context, "Rp. 20.000", "Almond"),
                            _card(context, "Rp. 20.000", "Stiletto"),
                          ]),

                          SizedBox(height: sH(30)),
                          _title("Choose Your Type Of Nails", sW),
                          SizedBox(height: sH(10)),
                          _horizontalScroll(sW, sH, [
                            _card(context, "Rp. 20.000", "Coffin"),
                            _card(context, "Rp. 20.000", "Almond"),
                            _card(context, "Rp. 20.000", "Stiletto"),
                          ]),

                          SizedBox(height: sH(40)),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AccessorisScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: sW(16),
                                  vertical: sH(8),
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF451A2B),
                                  borderRadius: BorderRadius.circular(sW(18)),
                                ),
                                child: Text(
                                  "Next",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: sW(14),
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: sH(40)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // BOTTOM NAVBAR
          Positioned(
            left: 0,
            top: sH(800),
            child: Container(
              width: sW(412),
              height: sH(120),
              padding: EdgeInsets.symmetric(
                vertical: sH(24),
                horizontal: sW(46),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(sW(27)),
                  topRight: Radius.circular(sW(27)),
                ),
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

  // Drawer Item
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

  // Title
  Widget _title(String text, Function sW) {
    return Text(
      text,
      style: TextStyle(
        color: const Color(0xFF451A2B),
        fontSize: sW(14),
        fontFamily: "Poppins",
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // Horizontal Scroll List
  Widget _horizontalScroll(Function sW, Function sH, List<Widget> children) {
    return SizedBox(
      height: sH(130),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...children.map(
              (e) => Padding(
                padding: EdgeInsets.only(right: sW(12)),
                child: e,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card
  Widget _card(BuildContext context, String price, String name) {
    return Container(
      width: Responsive.sW(context, 108),
      height: Responsive.sH(context, 130),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.sW(context, 5),
        vertical: Responsive.sH(context, 11),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFAF7C85),
        borderRadius: BorderRadius.circular(Responsive.sW(context, 12)),
      ),
      child: Column(
        children: [
          Container(
            width: Responsive.sW(context, 98),
            height: Responsive.sH(context, 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEAEE),
              borderRadius: BorderRadius.circular(Responsive.sW(context, 5)),
            ),
            child: Center(
              child: Text(
                price,
                style: TextStyle(
                  color: const Color(0xFF451A2B),
                  fontSize: Responsive.sW(context, 12),
                ),
              ),
            ),
          ),
          SizedBox(height: Responsive.sH(context, 6)),
          Container(
            width: Responsive.sW(context, 98),
            height: Responsive.sH(context, 78),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEAEE),
              borderRadius: BorderRadius.circular(Responsive.sW(context, 5)),
            ),
            child: Center(
              child: Text(
                name,
                style: TextStyle(
                  color: const Color(0xFF451A2B),
                  fontSize: Responsive.sW(context, 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Nav Item
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
}

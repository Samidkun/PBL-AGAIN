import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luxe_nail/screens/dashboard_screen.dart';
import 'package:luxe_nail/screens/gallery_screen.dart';
import 'package:luxe_nail/screens/profile_screen.dart';
import 'package:luxe_nail/utils/responsive.dart';
import 'package:luxe_nail/widgets/finishing/finishing_drawer.dart';

class FinishingScreen extends StatelessWidget {
  final String token;
  final Map<String, dynamic> user;
  final Map<String, dynamic>? selectedShape;
  final Map<String, dynamic>? selectedType;
  final Map<String, dynamic>? selectedColor;
  final Map<String, dynamic>? selectedAccessory;

  FinishingScreen({
    super.key,
    required this.token,
    required this.user,
    this.selectedShape,
    this.selectedType,
    this.selectedColor,
    this.selectedAccessory,
  });

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String formatRupiah(dynamic price) {
    int priceInt = int.tryParse(price.toString()) ?? 0;
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    ).format(priceInt);
  }

  @override
  Widget build(BuildContext context) {
    double sW(num v) => Responsive.sW(context, v);
    double sH(num v) => Responsive.sH(context, v);

    // Calculate Total
    int total = 0;
    total += int.tryParse(selectedShape?['price']?.toString() ?? '0') ?? 0;
    total += int.tryParse(selectedType?['price']?.toString() ?? '0') ?? 0;
    total += int.tryParse(selectedColor?['price']?.toString() ?? '0') ?? 0;
    total += int.tryParse(selectedAccessory?['price']?.toString() ?? '0') ?? 0;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFFEAEE),
      drawer: _buildDrawer(context),
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
                    'LUXE NAIL',
                    style: TextStyle(
                      color: const Color(0xFF975B73),
                      fontSize: sW(22),
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
            left: sW(13),
            top: sH(120),
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
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Opacity(
                      opacity: 0.5,
                      child: Image.asset(
                        "assets/images/Splas1-HAND.png",
                        width: sW(386),
                        height: sH(720),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // ================= CONTENT =================
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: sH(4)),
                      child: Column(
                        children: [
                          // ======== BANNER ========
                          Padding(
                            padding: EdgeInsets.only(bottom: sH(10)),
                            child: Image.asset(
                              "assets/images/struk-Vektor Tangan.png",
                              width: sW(350),
                              height: sH(120),
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: sH(10)),

                          // ======== TITLE ========
                          SizedBox(
                            width: sW(279),
                            child: Text(
                              "Here are your billing details.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF451A2B),
                                fontSize: sW(15),
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),

                          SizedBox(height: sH(20)),

                          // ======== STRUK / BILLING CARD ========
                          Container(
                            width: sW(304),
                            height: sH(365),
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
                            child: Stack(
                              children: [
                                // LOGO
                                Positioned(
                                  left: sW(137),
                                  top: sH(8),
                                  child: Container(
                                    width: sW(30),
                                    height: sH(33),
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          "assets/images/logout-Luxe Nail 2.png",
                                        ),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                _posText(
                                    sW(115), sH(41), "Luxe Nail", 16, true),
                                _posText(
                                    sW(102),
                                    sH(65),
                                    DateFormat('dd/MM/yyyy HH:mm')
                                        .format(DateTime.now()),
                                    9,
                                    false),
                                _posText(
                                    sW(62),
                                    sH(79),
                                    "Street. Fill with Address No.1/ABC Malang",
                                    9,
                                    false),
                                _posText(sW(84), sH(93),
                                    "Phone Number : 087723456781", 9, false),

                                _posText(sW(24), sH(131), "Shape :", 10, false),
                                _posText(sW(24), sH(164), "Type :", 10, false),
                                _posText(sW(24), sH(197), "Color :", 10, false),
                                _posText(
                                    sW(24), sH(228), "Accessory :", 10, false),
                                _posText(sW(118), sH(276), "Total :", 10, true),

                                // Values
                                _posText(sW(83), sH(131),
                                    selectedShape?['name'] ?? '-', 10, false),
                                _posText(sW(83), sH(164),
                                    selectedType?['name'] ?? '-', 10, false),
                                _posText(sW(83), sH(197),
                                    selectedColor?['name'] ?? '-', 10, false),
                                _posText(
                                    sW(83),
                                    sH(228),
                                    selectedAccessory?['name'] ?? '-',
                                    10,
                                    false),

                                // Prices
                                _posText(
                                    sW(225),
                                    sH(131),
                                    formatRupiah(selectedShape?['price'] ?? 0),
                                    10,
                                    false),
                                _posText(
                                    sW(225),
                                    sH(164),
                                    formatRupiah(selectedType?['price'] ?? 0),
                                    10,
                                    false),
                                _posText(
                                    sW(225),
                                    sH(197),
                                    formatRupiah(selectedColor?['price'] ?? 0),
                                    10,
                                    false),
                                _posText(
                                    sW(225),
                                    sH(228),
                                    formatRupiah(
                                        selectedAccessory?['price'] ?? 0),
                                    10,
                                    false),

                                // Total Price
                                _posText(sW(225), sH(276), formatRupiah(total),
                                    10, true),
                              ],
                            ),
                          ),

                          SizedBox(height: sH(25)),

                          // ======== CONFIRM BUTTON ========
                          GestureDetector(
                            onTap: () {
                              // Here we should probably save the reservation or something?
                              // But for now, just navigate back to dashboard as per original code.
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DashboardScreen(
                                    token: token,
                                    user: user,
                                  ),
                                ),
                                (route) => false,
                              );
                            },
                            child: Container(
                              width: sW(330),
                              height: sH(46),
                              decoration: BoxDecoration(
                                color: const Color(0xFF451A2B),
                                borderRadius: BorderRadius.circular(sW(14)),
                              ),
                              child: Center(
                                child: Text(
                                  "Confirm Order",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: sW(16),
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

  // ============================================================
  // DRAWER
  // ============================================================
  Widget _buildDrawer(BuildContext context) {
    return FinishingDrawer(
      token: token,
      user: user,
    );
  }

  // ============================================================
  // BOTTOM NAV
  // ============================================================
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
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F9),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Responsive.sW(context, 27)),
            topRight: Radius.circular(Responsive.sW(context, 27)),
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
            _bottomNavItem(
              context,
              "Back",
              Icons.arrow_back,
              () => Navigator.pop(context),
            ),
            _bottomNavItem(context, "Design", Icons.brush, () {}),
            _bottomNavItem(
              context,
              "Home",
              Icons.home,
              () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => DashboardScreen(token: token, user: user),
                ),
                (route) => false,
              ),
            ),
            _bottomNavItem(
              context,
              "Gallery",
              Icons.photo_album,
              () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => GalleryScreen(token: token, user: user),
                ),
                (route) => false,
              ),
            ),
            _bottomNavItem(
              context,
              "Profile",
              Icons.person,
              () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(token: token, user: user),
                ),
                (route) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavItem(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
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

// ========== HELPER UNTUK TEKS POSISI ==========
Widget _posText(double left, double top, String txt, double size, bool bold) {
  return Positioned(
    left: left,
    top: top,
    child: Text(
      txt,
      style: TextStyle(
        color: const Color(0xFF451A2B),
        fontSize: size,
        fontFamily: 'Poppins',
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      ),
    ),
  );
}

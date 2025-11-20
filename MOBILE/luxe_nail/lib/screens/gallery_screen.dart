import 'package:flutter/material.dart';
import 'package:luxe_nail/screens/dashboard_screen.dart';
//import 'package:luxe_nail/screens/jenis_treatment_screen.dart';
import 'package:luxe_nail/screens/login_screen.dart';
import 'package:luxe_nail/screens/profile_screen.dart';

class GalleryScreen extends StatelessWidget {
  final String token;
  final Map<String, dynamic> user;

  GalleryScreen({super.key, required this.token, required this.user});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ===================== DATA GALERI ======================
  final List<Map<String, String>> galleryData = [
  {
    "img": "assets/images/gallery/nail1.jpg",
    "name": "Elegant French",
    "desc": "Classic white tips with golden accents",
  },
  {
    "img": "assets/images/gallery/nail2.jpg",
    "name": "Sparkling Glitter",
    "desc": "Dazzling glitter with crystal details",
  },
  {
    "img": "assets/images/gallery/nail3.jpg",
    "name": "Floral Art",
    "desc": "Delicate hand-painted flower designs",
  },
  {
    "img": "assets/images/gallery/nail4.jpg",
    "name": "Marble Effect",
    "desc": "Sophisticated marble patterns",
  },
  {
    "img": "assets/images/gallery/nail5.jpg",
    "name": "Geometric Patterns",
    "desc": "Modern geometric designs",
  },
  {
    "img": "assets/images/gallery/nail6.jpg",
    "name": "Ombre Gradient",
    "desc": "Beautiful color transitions",
  },
  {
    "img": "assets/images/gallery/nail7.jpg",
    "name": "3D Nail Art",
    "desc": "Textured 3D designs",
  },
  {
    "img": "assets/images/gallery/nail8.jpg",
    "name": "Minimalist Style",
    "desc": "Simple yet elegant designs",
  },
  {
    "img": "assets/images/gallery/nail9.jpg",
    "name": "Chrome Finish",
    "desc": "Metallic chrome effects",
  },
  {
    "img": "assets/images/gallery/nail10.jpg",
    "name": "Animal Print",
    "desc": "Wild leopard and zebra patterns",
  },
  {
    "img": "assets/images/gallery/nail11.jpg",
    "name": "Holographic",
    "desc": "Rainbow holographic effects",
  },
  {
    "img": "assets/images/gallery/nail12.jpg",
    "name": "Stiletto Shape",
    "desc": "Edgy stiletto nail shape",
  },
  {
    "img": "assets/images/gallery/nail13.jpg",
    "name": "Coffin Shape",
    "desc": "Trendy coffin nail shape",
  },
  {
    "img": "assets/images/gallery/nail14.jpg",
    "name": "Almond Shape",
    "desc": "Elegant almond nail shape",
  },
  {
    "img": "assets/images/gallery/nail15.jpg",
    "name": "Bridal Style",
    "desc": "Elegant designs for special occasions",
  },
  {
    "img": "assets/images/gallery/nail16.jpg",
    "name": "Holiday Theme",
    "desc": "Festive Christmas designs",
  },
  {
    "img": "assets/images/gallery/nail17.jpg",
    "name": "Halloween Theme",
    "desc": "Spooky Halloween designs",
  },
  {
    "img": "assets/images/gallery/nail18.jpg",
    "name": "Summer Vibes",
    "desc": "Bright summer colors",
  },
  {
    "img": "assets/images/gallery/nail19.jpg",
    "name": "Abstract Art",
    "desc": "Modern abstract patterns",
  },
  {
    "img": "assets/images/gallery/nail20.jpg",
    "name": "Pearl Accents",
    "desc": "Elegant pearl decorations",
  },
];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    const figmaW = 412;
    const figmaH = 917;

    final sW = w / figmaW;
    final sH = h / figmaH;

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
                    radius: 30 * sW,
                    backgroundColor: const Color(0xFFFFEAEE),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFF451A2B),
                    ),
                  ),
                  SizedBox(height: 10 * sH),
                  Text(
                    'Welcome, ${user['name']}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF451A2B)),
              title: const Text(
                'Home',
                style: TextStyle(
                  color: Color(0xFF451A2B),
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DashboardScreen(token: token, user: user),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.brush, color: Color(0xFF451A2B)),
              title: const Text(
                'Jenis Treatment',
                style: TextStyle(
                  color: Color(0xFF451A2B),
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // onTap: () {
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => JenisTreatmentScreen(
              //       token: token,
              //       user: user,
              //     ),
              //    ),
              //   );
              // },
            ),
            const Divider(color: Color(0xFFAF7C85)),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF451A2B)),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFF451A2B),
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      // ================= BODY =================
      body: Stack(
        children: [
          // ================= HEADER =================
          Positioned(
            left: 26 * sW,
            top: 60 * sH,
            child: SizedBox(
              width: 351 * sW,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _scaffoldKey.currentState!.openDrawer(),
                    child: Icon(
                      Icons.menu,
                      size: 32 * sW,
                      color: const Color(0xFF451A2B),
                    ),
                  ),
                  Text(
                    'LUXE NAIL',
                    style: TextStyle(
                      color: const Color(0xFF975B73),
                      fontSize: 20 * sW,
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
            left: 13 * sW,
            top: 160 * sH,
            child: Container(
              width: 386 * sW,
              height: 720 * sH,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30 * sW),
                    topRight: Radius.circular(30 * sW),
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20 * sW),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Nail Design Gallery",
                      style: TextStyle(
                        color: const Color(0xFF451A2B),
                        fontSize: 22 * sW,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 20 * sH),

                    // ================= GALERI VERTICAL =================
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.only(top: 10 * sH),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,          // 2 kolom
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: galleryData.length,
                        itemBuilder: (context, index) {
                          final item = galleryData[index];

                          return GestureDetector(
                            onTap: () => _showImagePopup(
                              context,
                              item["img"]!,
                              item["name"]!,
                              item["desc"]!,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.asset(
                                item["img"]!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          // ================= BOTTOM NAVBAR =================
          Positioned(
            left: 0,
            top: 800 * sH,
            child: Container(
              width: 412 * sW,
              height: 120 * sH,
              padding: EdgeInsets.only(
                top: 24 * sH,
                left: 46 * sW,
                right: 46 * sW,
                bottom: 30 * sH,
              ),
              decoration: ShapeDecoration(
                color: const Color(0xFFFFF8F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(27 * sW),
                    topRight: Radius.circular(27 * sW),
                  ),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 9,
                    offset: Offset(5, -4),
                    spreadRadius: -1,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _bottomNavItem(
                    label: "Back",
                    icon: Icons.arrow_back,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  // _bottomNavItem(
                  //  label: "Design",
                  //  icon: Icons.brush,
                  //   onTap: () {
                  //    Navigator.pushAndRemoveUntil(
                  //     context,
                  //     MaterialPageRoute(
                  //      builder: (_) => JenisTreatmentScreen(
                  //       token: token,
                  //       user: user,
                  //    ),
                  //   ),
                  //   (route) => false,
                  //  );
                  //  },
                  //  ),
                  _bottomNavItem(
                    label: "Home",
                    icon: Icons.home,
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DashboardScreen(token: token, user: user),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                  _bottomNavItem(
                    label: "Gallery",
                    icon: Icons.photo_album,
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              GalleryScreen(token: token, user: user),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                  _bottomNavItem(
                    label: "Profile",
                    icon: Icons.person,
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(token: token),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= POPUP GALERI =================
  void _showImagePopup(
      BuildContext context, String imgPath, String title, String desc) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imgPath,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF451A2B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF975B73),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF975B73),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Close",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= BOTTOM NAV ITEM =================
  Widget _bottomNavItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF975B73), size: 32),
          const SizedBox(height: 5),
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

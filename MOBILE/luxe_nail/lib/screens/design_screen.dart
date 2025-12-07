import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:luxe_nail/screens/accessoris_screen.dart';
import 'package:luxe_nail/screens/dashboard_screen.dart';
import 'package:luxe_nail/screens/gallery_screen.dart';
import 'package:luxe_nail/screens/profile_screen.dart';
import 'package:luxe_nail/utils/responsive.dart';
import 'package:luxe_nail/widgets/design/design_drawer.dart';
import 'package:luxe_nail/widgets/design/design_category_card.dart';

class DesignScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;

  /// Reservation optional
  final Map<String, dynamic>? reservation;

  const DesignScreen({
    super.key,
    required this.token,
    required this.user,
    this.reservation,
  });

  @override
  State<DesignScreen> createState() => _DesignScreenState();
}

class _DesignScreenState extends State<DesignScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ================== API CONFIG ==================
  static const String _baseUrl =
      'https://unglorifying-rutha-insincerely.ngrok-free.dev';

  // ================== STATE DATA ==================
  List<Map<String, dynamic>> nailShapes = []; // type: nail_shape
  List<Map<String, dynamic>> nailTypes = []; // type: nail_type
  List<Map<String, dynamic>> nailColors = []; // type: color

  bool isLoading = false;
  String? errorMessage;

  // selected card per section
  int? selectedShapeId;
  int? selectedTypeId;
  int? selectedColorId;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // ================== FETCH CATEGORIES ==================
  Future<void> _fetchCategories() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final url = Uri.parse('$_baseUrl/api/v1/categories');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>? ?? {};

        setState(() {
          nailShapes = List<Map<String, dynamic>>.from(
            data['nail_shape'] ?? [],
          );
          nailTypes = List<Map<String, dynamic>>.from(data['nail_type'] ?? []);
          nailColors = List<Map<String, dynamic>>.from(data['color'] ?? []);
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load categories (code: ${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    double sW(num v) => Responsive.sW(context, v);
    double sH(num v) => Responsive.sH(context, v);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFFEAEE),

      // ================== DRAWER ==================
      drawer: DesignDrawer(
        token: widget.token,
        user: widget.user,
        sW: sW,
      ),

      // ================== BODY ==================
      body: Stack(
        children: [
          // HEADER
          Positioned(
            top: sH(60),
            left: sW(20),
            right: sW(20),
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

          // MAIN WHITE AREA
          Positioned(
            top: sH(140),
            left: sW(13),
            child: Container(
              width: sW(386),
              height: sH(720),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(sW(30)),
                ),
              ),
              child: _buildMain(context, sW, sH),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: _bottomNavbar(context, sW, sH),
          ),
        ],
      ),
    );
  }

  // ================== MAIN CONTENT ==================
  Widget _buildMain(
    BuildContext context,
    double Function(num) sW,
    double Function(num) sH,
  ) {
    // Kalau reservation belum dipilih
    if (widget.reservation == null) {
      return Stack(
        children: [
          Opacity(
            opacity: 0.9,
            child: Image.asset(
              "assets/images/Splas1-HAND.png",
              width: sW(386),
              height: sH(1000),
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Text(
              "Please select a reservation first",
              style: TextStyle(
                color: const Color(0xFF451A2B),
                fontSize: sW(16),
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
              ),
            ),
          ),
        ],
      );
    }

    // Loading / Error state
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFAF7C85)),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sW(16)),
          child: Text(
            errorMessage!,
            style: const TextStyle(
              color: Color(0xFF451A2B),
              fontFamily: "Poppins",
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Stack(
        children: [
          Opacity(
            opacity: 0.8,
            child: Image.asset(
              "assets/images/Splas1-HAND.png",
              width: sW(386),
              height: sH(1000),
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sW(20), vertical: sH(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========== NAIL SHAPE ==========
                _title("Choose Your Category Of Nails", sW),
                SizedBox(height: sH(10)),
                _horizontalScroll(
                  sW,
                  sH,
                  nailShapes,
                  selectedShapeId,
                  (id) => setState(() => selectedShapeId = id),
                ),

                SizedBox(height: sH(30)),

                // ========== NAIL TYPE ==========
                _title("Choose Your Type Of Nails", sW),
                SizedBox(height: sH(10)),
                _horizontalScroll(
                  sW,
                  sH,
                  nailTypes,
                  selectedTypeId,
                  (id) => setState(() => selectedTypeId = id),
                ),

                SizedBox(height: sH(30)),

                // ========== COLOR ==========
                _title("Choose Your Color Of Nails", sW),
                SizedBox(height: sH(10)),
                _horizontalScroll(
                  sW,
                  sH,
                  nailColors,
                  selectedColorId,
                  (id) => setState(() => selectedColorId = id),
                ),

                SizedBox(height: sH(40)),

                // NEXT BUTTON
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // nanti bisa kirim selectedShapeId, selectedTypeId, selectedColorId ke AccessorisScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AccessorisScreen(
                            token: widget.token,
                            user: widget.user,
                          ),
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
    );
  }

  // ================== COMPONENTS ==================
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

  Widget _title(String text, double Function(num) sw) {
    return Text(
      text,
      style: TextStyle(
        color: const Color(0xFF451A2B),
        fontSize: sw(14),
        fontFamily: "Poppins",
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Horizontal list untuk kategori (shape / type / color)
  Widget _horizontalScroll(
    double Function(num) sw,
    double Function(num) sh,
    List<Map<String, dynamic>> items,
    int? selectedId,
    void Function(int id) onSelected,
  ) {
    return SizedBox(
      height: sh(170), // sedikit lebih tinggi biar card lebih gede
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, i) => SizedBox(width: sw(12)),
        itemBuilder: (context, i) {
          final item = items[i];
          final bool isSelected = selectedId == item['id'];
          return _categoryCard(context, item, isSelected, onSelected);
        },
      ),
    );
  }

  Widget _categoryCard(
    BuildContext context,
    Map<String, dynamic> item,
    bool isSelected,
    void Function(int id) onSelected,
  ) {
    return DesignCategoryCard(
      item: item,
      isSelected: isSelected,
      onSelected: onSelected,
      baseUrl: _baseUrl,
    );
  }

  // ================== BOTTOM NAV ==================
  Widget _bottomNavbar(
    BuildContext context,
    double Function(num) sW,
    double Function(num) sH,
  ) {
    return Container(
      height: sH(90),
      padding: EdgeInsets.symmetric(horizontal: sW(40)),
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
          // BACK gantiin Home
          _bottomNavItem(
            label: "Back",
            icon: Icons.arrow_back,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DashboardScreen(token: widget.token, user: widget.user),
                ),
              );
            },
          ),
          _bottomNavItem(
            label: "Design",
            icon: Icons.brush,
            onTap: () {
              // sudah di halaman ini
            },
          ),
          _bottomNavItem(
            label: "Gallery",
            icon: Icons.photo_album,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      GalleryScreen(token: widget.token, user: widget.user),
                ),
              );
            },
          ),
          _bottomNavItem(
            label: "Profile",
            icon: Icons.person,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProfileScreen(token: widget.token, user: widget.user),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

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
          Icon(icon, size: 30, color: const Color(0xFF975B73)),
          const SizedBox(height: 3),
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

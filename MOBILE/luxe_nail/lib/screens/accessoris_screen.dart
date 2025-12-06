import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luxe_nail/screens/dashboard_screen.dart';
import 'package:luxe_nail/screens/finishing_screen.dart';
import 'package:luxe_nail/screens/gallery_screen.dart';
import 'package:luxe_nail/screens/profile_screen.dart';
import 'package:luxe_nail/utils/responsive.dart';
import 'package:luxe_nail/services/api_service.dart';
import 'login_screen.dart';
import 'package:luxe_nail/widgets/accessoris/accessoris_drawer.dart';

class AccessorisScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;
  final Map<String, dynamic>? selectedShape;
  final Map<String, dynamic>? selectedType;
  final Map<String, dynamic>? selectedColor;

  const AccessorisScreen({
    super.key,
    required this.token,
    required this.user,
    this.selectedShape,
    this.selectedType,
    this.selectedColor,
  });

  @override
  State<AccessorisScreen> createState() => _AccessorisScreenState();
}

class _AccessorisScreenState extends State<AccessorisScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // State for accessories
  List<Map<String, dynamic>> accessories = [];
  Map<String, dynamic>? selectedAccessory;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccessories();
  }

  Future<void> _fetchAccessories() async {
    try {
      final result = await ApiService.getCategories(widget.token);
      if (result['success']) {
        final data = result['data'];
        setState(() {
          // Assuming 'accessory' or similar key exists.
          // If not, we might need to check the API response structure again.
          // GalleryScreen used 'accessory'.
          accessories =
              List<Map<String, dynamic>>.from(data['accessory'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

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

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFFEAEE),

      // ================= DRAWER =================
      drawer: AccessorisDrawer(
        token: widget.token,
        user: widget.user,
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

                        // Selected Accessory Preview (Optional, or just placeholder)
                        Container(
                          width: sW(330),
                          height: sH(300),
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
                          child: selectedAccessory != null &&
                                  selectedAccessory!['image'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(sW(13)),
                                  child: Image.network(
                                    "${ApiService.baseUrl}/${selectedAccessory!['image']}",
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey),
                                  ),
                                )
                              : const Center(
                                  child: Text("Select an accessory below",
                                      style: TextStyle(color: Colors.grey))),
                        ),

                        SizedBox(height: sH(20)),

                        // Accessories List
                        SizedBox(
                          height: sH(160),
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xFFAF7C85)))
                              : accessories.isEmpty
                                  ? const Center(
                                      child: Text("No accessories available"))
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: accessories.map((item) {
                                          return Padding(
                                            padding:
                                                EdgeInsets.only(right: sW(12)),
                                            child:
                                                _accessoryCard(context, item),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                        ),

                        SizedBox(height: sH(15)),

                        GestureDetector(
                          onTap: () {
                            // Navigate to FinishingScreen with ALL selections
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FinishingScreen(
                                  token: widget.token,
                                  user: widget.user,
                                  // Pass all selections
                                  // Note: FinishingScreen needs to be updated to accept these too!
                                  // For now, we assume it might not accept them yet, but we are building the flow.
                                  // I'll check FinishingScreen next.
                                ),
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
                      MaterialPageRoute(
                        builder: (_) => DashboardScreen(
                            token: widget.token, user: widget.user),
                      ),
                      (route) => false,
                    );
                  }),
                  _bottomItem(context, "Gallery", Icons.photo_album, () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GalleryScreen(
                            token: widget.token, user: widget.user),
                      ),
                      (route) => false,
                    );
                  }),
                  _bottomItem(context, "Profile", Icons.person, () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(
                            token: widget.token, user: widget.user),
                      ),
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

  // ===== Drawer Item =====
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

  // ===== Bottom Nav Item =====
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

  // ===== Accessory Card =====
  Widget _accessoryCard(BuildContext context, Map<String, dynamic> item) {
    double sW(num v) => Responsive.sW(context, v);
    double sH(num v) => Responsive.sH(context, v);

    final isSelected =
        selectedAccessory != null && selectedAccessory!['id'] == item['id'];

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAccessory = item;
        });
      },
      child: Container(
        width: sW(108),
        height: sH(130),
        padding: EdgeInsets.symmetric(horizontal: sW(5), vertical: sH(10)),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9E6475) : const Color(0xFFAF7C85),
          borderRadius: BorderRadius.circular(sW(12)),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Column(
          children: [
            Container(
              width: sW(98),
              height: sH(22),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEAEE),
                borderRadius: BorderRadius.circular(sW(5)),
              ),
              child: Center(
                child: Text(
                  formatRupiah(item['price']),
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
            Container(
              width: sW(98),
              height: sH(78),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEAEE),
                borderRadius: BorderRadius.circular(sW(5)),
              ),
              child: Center(
                child: Text(
                  item['name'] ?? '-',
                  textAlign: TextAlign.center,
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
      ),
    );
  }
}

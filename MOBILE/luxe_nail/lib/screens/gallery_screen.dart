import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luxe_nail/screens/dashboard_screen.dart';
import 'package:luxe_nail/screens/login_screen.dart';
import 'package:luxe_nail/screens/profile_screen.dart';
import 'package:luxe_nail/services/api_service.dart';

class GalleryScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;

  const GalleryScreen({super.key, required this.token, required this.user});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  bool _isLoading = true;
  Map<String, dynamic> categories = {
    "shape": [],
    "color": [],
    "finish": [],
    "accessory": [],
  };

  @override
  void initState() {
    super.initState();
    _fetchCatalog();
  }

  Future<void> _fetchCatalog() async {
    final result = await ApiService.getCategories(widget.token);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success']) {
        categories = result['data'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load catalog: ${result['message']}")),
        );
      }
    });
  }

  String formatRupiah(dynamic price) {
    int priceInt = int.tryParse(price.toString()) ?? 0;
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(priceInt);
  }

  @override
  Widget build(BuildContext context) {
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
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFFFEAEE),
                    child: Icon(Icons.person, size: 40, color: Color(0xFF451A2B)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome, ${widget.user['username']}!',
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
              title: const Text("Home", style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF451A2B))),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => DashboardScreen(token: widget.token, user: widget.user)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_album, color: Color(0xFF451A2B)),
              title: const Text("Catalog", style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF451A2B))),
              onTap: () => Navigator.pop(context), // Already here
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF451A2B)),
              title: const Text("Profile", style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF451A2B))),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen(token: widget.token)),
                );
              },
            ),
            const Divider(color: Color(0xFFAF7C85)),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF451A2B)),
              title: const Text("Logout", style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF451A2B))),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),

          // HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _scaffoldKey.currentState!.openDrawer(),
                  child: const Icon(Icons.menu, size: 32, color: Color(0xFF451A2B)),
                ),
                const Text(
                  'LUXE NAIL',
                  style: TextStyle(
                    color: Color(0xFF975B73),
                    fontSize: 22,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // TITLE
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 26),
            child: Text(
              "Nail Art Catalog & Pricing",
              style: TextStyle(
                color: Color(0xFF451A2B),
                fontSize: 24,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // CATALOG CONTENT
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFAF7C85)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCategorySection("Shapes", categories['shape']),
                          _buildCategorySection("Colors", categories['color']),
                          _buildCategorySection("Finishes", categories['finish']),
                          _buildCategorySection("Accessories", categories['accessory']),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String title, List<dynamic>? items) {
    if (items == null || items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF975B73),
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = items[index];
            final imageUrl = item['image'] != null 
                ? "${ApiService.baseUrl}/storage/${item['image']}" 
                : null;

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      )
                    : const Icon(Icons.image, color: Colors.grey),
              ),
              title: Text(
                item['name'] ?? '-',
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF451A2B),
                ),
              ),
              trailing: Text(
                formatRupiah(item['price']),
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFAF7C85),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

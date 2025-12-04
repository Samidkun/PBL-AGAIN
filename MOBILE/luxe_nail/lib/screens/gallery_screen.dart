import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:luxe_nail/screens/dashboard_screen.dart';
import 'package:luxe_nail/screens/login_screen.dart';
import 'package:luxe_nail/screens/profile_screen.dart';
import 'package:luxe_nail/screens/ai_screen.dart'; // Import CustomDesignView
import 'package:luxe_nail/services/api_service.dart';

class GalleryScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;
  final Map<String, dynamic>? reservation; // Add reservation

  const GalleryScreen({
    super.key,
    required this.token,
    required this.user,
    this.reservation,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // Removed GlobalKey

  @override
  void initState() {
    super.initState();
  }

  Future<void> _finishJob() async {
    if (widget.reservation == null) return;

    // Confirm dialog
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Finish Appointment"),
            content: const Text(
                "Are you sure you want to mark this appointment as completed?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Finish")),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    final result =
        await ApiService.finishJob(widget.token, widget.reservation!['id']);
    if (result['success']) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Job completed successfully!")));
      Navigator.pop(context, true); // Return true to refresh dashboard
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // Removed key: _scaffoldKey
        backgroundColor: const Color(0xFFFFF1F3),
        drawer: _buildDrawer(),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF1F3),
          elevation: 0,
          leading: Builder(
            builder: (context) => GestureDetector(
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.pop(context);
                } else {
                  Scaffold.of(context).openDrawer();
                }
              },
              child: Icon(
                Navigator.of(context).canPop()
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.menu,
                color: const Color(0xFF451A2B),
              ),
            ),
          ),
          centerTitle: true,
          title: const Text(
            "LUXE NAIL",
            style: TextStyle(
                color: Color(0xFF975B73),
                fontSize: 22,
                fontFamily: 'Georgia',
                fontWeight: FontWeight.w700),
          ),
          bottom: const TabBar(
            labelColor: Color(0xFF975B73),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF975B73),
            tabs: [
              Tab(text: "Templates"),
              Tab(text: "Custom Design"),
            ],
          ),
          actions: [
            if (widget.reservation != null)
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: _finishJob,
                tooltip: "Finish Appointment",
              )
          ],
        ),
        body: TabBarView(
          children: [
            // TAB 1: TEMPLATES (Static Gallery)
            _buildTemplatesTab(),

            // TAB 2: CUSTOM DESIGN (Refactored AI Screen)
            widget.reservation != null
                ? CustomDesignView(
                    token: widget.token,
                    user: widget.user,
                    reservation: widget.reservation)
                : const Center(
                    child:
                        Text("Select a reservation to create a custom design")),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFFFFF8F9),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFFAF7C85), Color(0xFF975B73)])),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFFFEAEE),
                    child:
                        Icon(Icons.person, size: 40, color: Color(0xFF451A2B))),
                const SizedBox(height: 12),
                Text('Welcome,',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9), fontSize: 14)),
                Text(widget.user['username'] ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_rounded, color: Color(0xFF451A2B)),
            title: const Text("Home",
                style:
                    TextStyle(fontFamily: 'Poppins', color: Color(0xFF451A2B))),
            onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => DashboardScreen(
                        token: widget.token, user: widget.user))),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded,
                color: Color(0xFFAF7C85)),
            title: const Text("Gallery",
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFFAF7C85),
                    fontWeight: FontWeight.w600)),
            tileColor: const Color(0xFFFFEAEE),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person_rounded, color: Color(0xFF451A2B)),
            title: const Text("Profile",
                style:
                    TextStyle(fontFamily: 'Poppins', color: Color(0xFF451A2B))),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProfileScreen(token: widget.token)));
            },
          ),
          const Divider(color: Color(0xFFE5C1C8), thickness: 1),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Color(0xFF975B73)),
            title: const Text("Logout",
                style:
                    TextStyle(fontFamily: 'Poppins', color: Color(0xFF975B73))),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false);
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HELPER: FORMAT RUPIAH
  // ==========================================================
  String formatRupiah(dynamic price) {
    int priceInt = int.tryParse(price.toString()) ?? 0;
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(priceInt);
  }

  void _showTemplateDetails(Map<String, dynamic> template) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Template Details",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF451A2B),
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow("Shape", template['shape']),
              const Divider(),
              _buildDetailRow("Color", template['color']),
              const Divider(),
              _buildDetailRow("Finish", template['finish']),
              const Divider(),
              _buildDetailRow("Accessory", template['accessory']),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F3),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFE5C1C8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Price",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF451A2B),
                      ),
                    ),
                    Text(
                      formatRupiah(template['price']),
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF975B73),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close bottom sheet
                    _confirmSelection(template);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF975B73),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: const Color(0xFF975B73).withOpacity(0.4),
                  ),
                  child: const Text(
                    "Select This Design",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSelection(Map<String, dynamic> template) async {
    if (widget.reservation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No active reservation found.")),
      );
      return;
    }

    // Calculate new total price
    int currentTotal =
        int.tryParse(widget.reservation!['total_price'].toString()) ?? 0;
    int templatePrice = int.tryParse(template['price'].toString()) ?? 0;

    int newTotal = currentTotal + templatePrice;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await ApiService.updateReservation(
      widget.token,
      widget.reservation!['id'],
      {
        'total_price': newTotal,
      },
    );

    if (!mounted) return;
    Navigator.pop(context); // Close loading

    if (result['success']) {
      // Show Digital Receipt / Success Message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Design Confirmed!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Your selection has been sent to the cashier."),
              const SizedBox(height: 10),
              const Divider(),
              Text("Item: ${template['shape']} - ${template['color']}"),
              Text("Price: ${formatRupiah(template['price'])}"),
              const Divider(),
              Text(
                "New Total: ${formatRupiah(newTotal)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Optionally refresh dashboard or reservation data here
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result['message'] ?? "Failed to confirm selection")),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF451A2B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesTab() {
    // Dummy Data for Templates
    final List<Map<String, dynamic>> templates = [
      {
        'image': 'assets/images/gallery/nail1.jpg',
        'shape': 'Almond',
        'color': 'Soft Pink',
        'finish': 'Glossy',
        'accessory': 'Gold Foil',
        'price': 145000
      },
      {
        'image': 'assets/images/gallery/nail2.jpg',
        'shape': 'Coffin',
        'color': 'Nude Beige',
        'finish': 'Matte',
        'accessory': 'Swarovski Crystal',
        'price': 180000
      },
      {
        'image': 'assets/images/gallery/nail3.jpg',
        'shape': 'Stiletto',
        'color': 'Midnight Black',
        'finish': 'Glossy',
        'accessory': 'Silver Chain',
        'price': 165000
      },
      {
        'image': 'assets/images/gallery/nail4.jpg',
        'shape': 'Square',
        'color': 'Pearl White',
        'finish': 'Shimmer',
        'accessory': 'None',
        'price': 110000
      },
      {
        'image': 'assets/images/gallery/nail5.jpg',
        'shape': 'Oval',
        'color': 'Pastel Blue',
        'finish': 'Matte',
        'accessory': 'Floral Sticker',
        'price': 130000
      },
      {
        'image': 'assets/images/gallery/nail6.jpg',
        'shape': 'Almond',
        'color': 'Emerald Green',
        'finish': 'Cat Eye',
        'accessory': 'None',
        'price': 155000
      },
      {
        'image': 'assets/images/gallery/nail7.jpg',
        'shape': 'Squoval',
        'color': 'Lavender',
        'finish': 'Glossy',
        'accessory': 'Glitter Ombre',
        'price': 140000
      },
      {
        'image': 'assets/images/gallery/nail8.jpg',
        'shape': 'Coffin',
        'color': 'Burgundy',
        'finish': 'Glossy',
        'accessory': 'Gold Line Art',
        'price': 170000
      },
    ];

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          return GestureDetector(
            onTap: () => _showTemplateDetails(template),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Image.asset(
                      template['image'],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatRupiah(template['price']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const Text(
                              "Tap for details",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
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
          );
        },
      ),
    );
  }
}

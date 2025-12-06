import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:luxe_nail/screens/dashboard_screen.dart';
import 'package:luxe_nail/screens/login_screen.dart';
import 'package:luxe_nail/screens/profile_screen.dart';
import 'package:luxe_nail/screens/ai_screen.dart'; // kalau masih butuh nanti
import 'package:luxe_nail/services/api_service.dart';

class GalleryScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;
  final Map<String, dynamic>? reservation; // optional

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
  // === dari katalog lama ===
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  Map<String, dynamic> categories = {
    "shape": [],
    "color": [],
    "finish": [],
    "accessory": [],
  };

  String? selectedCategoryFilter;
  String selectedTypeFilter = "all"; // Filter untuk Nail Art / Extension

  // Mapping untuk Nail Extension items
  final Set<String> nailExtensionItems = {
    // Shape
    'coffin (ballerina)', 'stiletto', 'almond', 'russian almond',
    // Color
    'royal gold', 'platinum silver', 'black emerald', 'burgendy wine', 'burgundy wine', 'rose gold', 'rolse gold',
    // Finish
    'holographic', 'holograpic', 'chrome powder', 'cat eye 9d', 'velvet touch',
    // Accessories
    'swarovski crystals', '3d acrylic flower', 'gold foil flakes', 'genuine pearls', 'encapsulated art',
  };

  // Mapping untuk Nail Art items
  final Set<String> nailArtItems = {
    // Shape
    'natural round', 'soft square', 'oval',
    // Color
    'classic red', 'nude pink', 'midnight blue', 'pure black', 'white',
    // Finish
    'glossy', 'matte',
    // Accessories
    'simple glitter', 'minimalist line', 'small sticker',
  };
  // === end katalog lama ===

  @override
  void initState() {
    super.initState();
    // panggil fetch catalog (dari katalog lama)
    _fetchCatalog();
  }

  // ================== JOB FINISH (dari Gallery baru) ==================
  Future<void> _finishJob() async {
    if (widget.reservation == null) return;

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
          .showSnackBar(SnackBar(content: Text(result['message'] ?? '')));
    }
  }

  // ================== FETCH CATALOG (dari katalog lama) ==================
  Future<void> _fetchCatalog() async {
    try {
      final result = await ApiService.getCategories(widget.token);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (result['success']) {
          categories = result['data'] ?? categories;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to load catalog: ${result['message']}")),
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading catalog: $e")),
      );
    }
  }

  // ================== HELPERS (gabungan: formatRupiah & show detail) ==================
  String formatRupiah(dynamic price) {
    int priceInt = int.tryParse(price.toString()) ?? 0;
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(priceInt);
  }

  // Helper function to determine item type based on name (dari katalog lama)
  String getItemType(Map<String, dynamic> item) {
    final itemName = (item['name'] ?? '').toString().toLowerCase().trim();

    if (nailExtensionItems.contains(itemName)) {
      return 'Nail Extension';
    } else if (nailArtItems.contains(itemName)) {
      return 'Nail Art';
    }

    // Fallback: gunakan type dari backend jika ada
    return item['type'] ?? 'Unknown';
  }

  // Show detail popup (dari katalog lama)
  void _showItemDetail(Map<String, dynamic> item) {
    final imageUrl = item['image'] != null
        ? "${ApiService.baseUrl}/${item['image']}"
        : null;

    final itemType = getItemType(item); // Get type based on name

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        height: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 300,
                            alignment: Alignment.center,
                            color: Colors.grey[200],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.broken_image, size: 80, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Failed to load image', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 300,
                            alignment: Alignment.center,
                            color: Colors.grey[100],
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Color(0xFFAF7C85),
                            ),
                          );
                        },
                      )
                    : Container(
                        height: 300,
                        alignment: Alignment.center,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 80),
                      ),
              ),

              // Details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: itemType == 'Nail Extension'
                            ? Colors.blueAccent
                            : Colors.pinkAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        itemType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    Text(
                      item['name'] ?? '-',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF451A2B),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      item['description'] ?? "No description",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price
                    Row(
                      children: [
                        const Text(
                          "Price: ",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          formatRupiah(item['price']),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Color(0xFFAF7C85),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFAF7C85),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Close",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
    );
  }

  // ================== BUILD (appBar + tabs) ==================
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Templates + Custom Design (di sini kita tampilkan katalog lama)
      child: Scaffold(
        key: _scaffoldKey,
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
            // TAB 1: existing Templates tab (tetap utuh)
            _buildTemplatesTab(),

            // TAB 2: Custom Design -> kita masukkan katalog lama di sini
            _buildCustomDesignCatalogTab(),
          ],
        ),
      ),
    );
  }

  // ================== DRAWER (ambil dari salah satu versi, tetap sama) ==================
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

  // ================== TEMPLATES TAB (tetap seperti kode baru) ==================
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

  // helper untuk show template details (dipakai di templates tab)
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

  // dipakai saat user pilih template (mengupdate reservation)
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
                // AUTO-FINISH: Navigate back to Dashboard
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/dashboard', (route) => false);
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

  // ================== CUSTOM DESIGN TAB: katalog lama dimasukkan di sini ==================
  Widget _buildCustomDesignCatalogTab() {
    // This replicates the body from katalog lama (type toggle, filter bar, sections)
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFAF7C85)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeToggle(), // All / Nail Art / Nail Extension
                  const SizedBox(height: 16),
                  _buildFilterBar(),
                  const SizedBox(height: 20),
                  ..._buildFilteredSections(),
                ],
              ),
            ),
    );
  }

  // ================== WIDGET-HELPERS dari katalog lama ==================
  Widget _buildHeader() {
    final bool canPop = Navigator.of(context).canPop();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // back/menu icon
          GestureDetector(
            onTap: () {
              if (canPop) {
                Navigator.pop(context);
              } else {
                _scaffoldKey.currentState!.openDrawer();
              }
            },
            child: Icon(
              canPop ? Icons.arrow_back_ios_new_rounded : Icons.menu,
              size: 25,
              color: const Color(0xFF451A2B),
            ),
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
    );
  }

  Widget _buildTitle() {
    return const Padding(
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
    );
  }

  Widget _buildTypeToggle() {
    return Row(
      children: [
        Expanded(
          child: _buildTypeButton("All", "all"),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTypeButton("Nail Art", "Nail Art"),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTypeButton("Nail Extension", "Nail Extension"),
        ),
      ],
    );
  }

  Widget _buildTypeButton(String label, String value) {
    final isSelected = selectedTypeFilter == value;

    return InkWell(
      onTap: () {
        setState(() {
          selectedTypeFilter = value;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFFAF7C85),
                    Color(0xFF975B73),
                  ],
                )
              : null,
          color: isSelected ? null : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFAF7C85).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF451A2B),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE6ED),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategoryFilter,
          hint: const Text("Filter by category", style: TextStyle(fontSize: 14)),
          items: const [
            DropdownMenuItem(value: "all", child: Text("All Categories")),
            DropdownMenuItem(value: "shape", child: Text("Shape")),
            DropdownMenuItem(value: "color", child: Text("Color")),
            DropdownMenuItem(value: "finish", child: Text("Finish")),
            DropdownMenuItem(value: "accessory", child: Text("Accessory")),
          ],
          onChanged: (value) {
            setState(() {
              selectedCategoryFilter = value;
            });
          },
          isExpanded: true,
          style: const TextStyle(color: Color(0xFF451A2B), fontFamily: 'Poppins'),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
      ),
    );
  }

  List<Widget> _buildFilteredSections() {
    final categoryKeys = ['shape', 'color', 'finish', 'accessory'];
    final categoryTitles = ['Shapes', 'Colors', 'Finishes', 'Accessories'];

    List<Widget> sections = [];

    for (int i = 0; i < categoryKeys.length; i++) {
      if (selectedCategoryFilter == null ||
          selectedCategoryFilter == 'all' ||
          selectedCategoryFilter == categoryKeys[i]) {
        sections.add(
          _buildCategorySection(categoryTitles[i], categories[categoryKeys[i]]),
        );
      }
    }

    return sections;
  }

  Widget _buildCategorySection(String title, List<dynamic>? items) {
    if (items == null || items.isEmpty) return const SizedBox.shrink();

    // Filter items by type using getItemType function
    List<dynamic> filteredItems = items.where((item) {
      if (selectedTypeFilter == "all") return true;
      return getItemType(item) == selectedTypeFilter;
    }).toList();

    if (filteredItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF975B73),
            ),
          ),
        ),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.68,
          ),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            final itemType = getItemType(item); // Get type based on name

            final imageUrl = item['image'] != null
                ? "${ApiService.baseUrl}/${item['image']}"
                : null;

            return Stack(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black12,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _showItemDetail(item), // Show popup on tap
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            child: imageUrl != null
                                ? Image.network(
                                    imageUrl,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        color: Colors.grey[200],
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                            SizedBox(height: 4),
                                            Text('Image Error', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                          ],
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        alignment: Alignment.center,
                                        color: Colors.grey[100],
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                              : null,
                                          color: Color(0xFFAF7C85),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image, size: 40),
                                  ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item['name'] ?? '-',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF451A2B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['description'] ?? "No description",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                formatRupiah(item['price']),
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFFAF7C85),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: itemType == 'Nail Extension'
                          ? Colors.blueAccent
                          : Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      itemType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // small helper row for template details bottom sheet
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
}
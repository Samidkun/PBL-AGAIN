import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Pastikan import file result screen-mu benar
import 'ai_result_screen.dart';

class AIScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;
  final Map<String, dynamic>? reservation;

  const AIScreen({
    super.key,
    required this.token,
    required this.user,
    this.reservation,
  });

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  bool _loading = false;

  // Data Kategori dari Backend
  Map<String, dynamic> categories = {
    "shape": [],
    "color": [],
    "finish": [],
    "accessory": [],
  };

  // Pilihan User
  String? selectedShape;
  String? selectedColor;
  String? selectedFinish;
  String? selectedAccessory;

  final TextEditingController customPromptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  @override
  void dispose() {
    customPromptController.dispose();
    super.dispose();
  }

  // ==========================================================
  // 1. FETCH CATEGORIES (Ambil data dari Laravel)
  // ==========================================================
  Future<void> fetchCategories() async {
    final baseUrl = dotenv.env['BASE_URL'];
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/categories"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${widget.token}",
          "ngrok-skip-browser-warning": "true",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          categories = data["data"];
        });
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  // ==========================================================
  // 2. HELPER: CARI ITEM & HARGA
  // ==========================================================
  Map<String, dynamic>? findFullItem(
    String categoryType,
    String? selectedName,
  ) {
    if (selectedName == null) return null;
    List list = categories[categoryType] ?? [];

    var foundItem = list.firstWhere(
      (item) => item['name'] == selectedName,
      orElse: () => null,
    );

    return foundItem;
  }

  // ==========================================================
  // 3. BUILD PROMPT (VERSI NARASI)
  // ==========================================================
  // Gantikan function buildPrompt() di AIScreen.dart dengan kode ini

  String buildPrompt() {
    // 1. START: Gunakan keywords yang kuat dan singkat untuk pembukaan
    String prompt = "Macro photo, professional nail art design. ";

    // 2. SPESIFIKASI: Gunakan format KEY: VALUE
    if (selectedShape != null) {
      // Kita hilangkan kata "The nail shape must be strictly"
      prompt += "Shape: ${selectedShape}. ";
    }

    if (selectedColor != null) {
      prompt += "Color: ${selectedColor}. ";
    }

    if (selectedFinish != null) {
      prompt += "Finish: ${selectedFinish}. ";
    }

    if (selectedAccessory != null) {
      prompt += "Accessory: ${selectedAccessory}. ";
    }

    // 3. CUSTOM PROMPT
    if (customPromptController.text.isNotEmpty) {
      prompt += "Details: ${customPromptController.text.trim()}. ";
    }

    // 4. KUALITAS: Gunakan koma untuk mempersingkat booster
    prompt += "Photorealistic, high detail, 8k, cinematic lighting, elegant.";

    print("SENDING PROMPT (Optimized): $prompt");

    return prompt;
  }

  // ==========================================================
  // 4. GENERATE IMAGE & NAVIGASI (FIXED ERROR 'token')
  // ==========================================================
  Future<void> generateImage() async {
    if (widget.reservation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error: No active reservation found."),
        ),
      );
      return;
    }

    final prompt = buildPrompt();
    if (prompt.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select options or input prompt")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final url = Uri.parse("$baseUrl/api/v1/ai/generate");

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode({
          "prompt": prompt,
          "reservation_id": widget.reservation?['id'],
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // --- SUKSES ---
        String finalImageUrl = data['image_url'];

        // A. Ambil Data Item Lengkap (untuk Harga & Nama)
        var shapeItem = findFullItem('shape', selectedShape);
        var colorItem = findFullItem('color', selectedColor);
        var finishItem = findFullItem('finish', selectedFinish);
        var accessoryItem = findFullItem('accessory', selectedAccessory);

        // B. Hitung Harga Satuan
        int pShape = int.tryParse(shapeItem?['price'].toString() ?? '0') ?? 0;
        int pColor = int.tryParse(colorItem?['price'].toString() ?? '0') ?? 0;
        int pFinish = int.tryParse(finishItem?['price'].toString() ?? '0') ?? 0;
        int pAccessory =
            int.tryParse(accessoryItem?['price'].toString() ?? '0') ?? 0;
        int basePrice =
            int.tryParse(widget.reservation?['price'].toString() ?? '0') ?? 0;

        // C. Hitung Total
        int grandTotal = basePrice + pShape + pColor + pFinish + pAccessory;

        setState(() => _loading = false);

        // D. Navigasi ke Screen Result (dengan FIX: token: widget.token)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AIResultScreen(
              // === FIX ERROR: MENGIRIM TOKEN YANG DIBUTUHKAN ===
              token: widget.token,

              imageUrl: finalImageUrl,

              // Data Pilihan User
              shape: selectedShape,
              color: selectedColor,
              finish: selectedFinish,
              accessory: selectedAccessory,

              // Data Harga
              priceShape: pShape,
              priceColor: pColor,
              priceFinish: pFinish,
              priceAccessory: pAccessory,

              // Total & Info Reservasi
              totalPrice: grandTotal,
              reservation: widget.reservation,
            ),
          ),
        );
      } else {
        // --- ERROR DARI BACKEND ---
        String msg = data['message'] ?? "Unknown error occurred";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(msg)),
        );
        setState(() => _loading = false);
      }
    } catch (e) {
      // --- ERROR KONEKSI ---
      print("Connection Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Connection failed: $e"),
        ),
      );
      setState(() => _loading = false);
    }
  }

  // ==========================================================
  // WIDGET & UI BUILD (Biarkan sama)
  // ==========================================================
  Widget optionButton(
    String label,
    String? selected,
    VoidCallback? onTap, {
    bool disabled = false,
  }) {
    final isSelected = label == selected;

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.3 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          margin: const EdgeInsets.only(right: 8, bottom: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFAF7C85) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFAF7C85)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF451A2B),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExtension =
        widget.reservation?["treatment_type"] == "nail_extension";

    return Scaffold(
      backgroundColor: const Color(0xFFFFEAEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFEAEE),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "AI Nail Design",
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF451A2B),
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF451A2B)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SHAPE
            const Text(
              "Shape",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF451A2B),
              ),
            ),
            Wrap(
              children: [
                for (var item in categories["shape"])
                  optionButton(
                    item["name"],
                    selectedShape,
                    () => setState(() => selectedShape = item["name"]),
                    disabled: !isExtension,
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // COLOR
            const Text(
              "Color",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF451A2B),
              ),
            ),
            Wrap(
              children: [
                for (var item in categories["color"])
                  optionButton(
                    item["name"],
                    selectedColor,
                    () => setState(() => selectedColor = item["name"]),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // FINISH
            const Text(
              "Finish",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF451A2B),
              ),
            ),
            Wrap(
              children: [
                for (var item in categories["finish"])
                  optionButton(
                    item["name"],
                    selectedFinish,
                    () => setState(() => selectedFinish = item["name"]),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // ACCESSORY
            const Text(
              "Accessory",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF451A2B),
              ),
            ),
            Wrap(
              children: [
                for (var item in categories["accessory"])
                  optionButton(
                    item["name"],
                    selectedAccessory,
                    () => setState(() => selectedAccessory = item["name"]),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // CUSTOM PROMPT
            const Text(
              "Custom Prompt (optional)",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF451A2B),
              ),
            ),
            TextField(
              controller: customPromptController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFFFF8F9),
                hintText: "E.g. A starry night theme...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFAF7C85)),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 30),

            // GENERATE BUTTON
            Center(
              child: GestureDetector(
                onTap: _loading ? null : generateImage,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _loading ? Colors.grey : const Color(0xFFAF7C85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Generate Design",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
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

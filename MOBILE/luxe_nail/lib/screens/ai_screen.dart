import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luxe_nail/services/api_service.dart';
import 'ai_result_screen.dart';

class CustomDesignView extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;
  final Map<String, dynamic>? reservation;

  const CustomDesignView({
    super.key,
    required this.token,
    required this.user,
    this.reservation,
  });

  @override
  State<CustomDesignView> createState() => _CustomDesignViewState();
}

class _CustomDesignViewState extends State<CustomDesignView> {
  bool _loading = false;
  final PageController _pageController = PageController();
  int _currentStep = 0;
  int _generationCount = 0;
  final int _maxGenerations = 3;

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

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ==========================================================
  // 1. FETCH CATEGORIES (Ambil data dari Laravel)
  // ==========================================================
  Future<void> fetchCategories() async {
    final result = await ApiService.getCategories(widget.token);

    if (result['success']) {
      if (mounted) {
        setState(() {
          categories = result['data'];
        });
      }
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
  String buildPrompt() {
    String prompt = "Macro photo, professional nail art design. ";

    if (selectedShape != null) prompt += "Shape: $selectedShape. ";
    if (selectedColor != null) prompt += "Color: $selectedColor. ";
    if (selectedFinish != null) prompt += "Finish: $selectedFinish. ";
    if (selectedAccessory != null) prompt += "Accessory: $selectedAccessory. ";

    prompt += "Photorealistic, high detail, 8k, cinematic lighting, elegant.";
    return prompt;
  }

  // ==========================================================
  // 4. GENERATE IMAGE & NAVIGASI
  // ==========================================================
  Future<void> generateImage() async {
    if (!mounted) return;

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
    if (selectedShape == null &&
        selectedColor == null &&
        selectedFinish == null &&
        selectedAccessory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one option")),
      );
      return;
    }

    if (_generationCount >= _maxGenerations) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Limit reached: You can only generate 3 designs."),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final result = await ApiService.generateAIImage(
      widget.token,
      prompt,
      widget.reservation?['id'],
    );

    if (!mounted) return;

    if (result['success']) {
      String? finalImageUrl = result['image_url'];

      if (finalImageUrl == null || finalImageUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.red,
              content: Text("Error: Generated image URL is missing.")),
        );
        setState(() => _loading = false);
        return;
      }

      var shapeItem = findFullItem('shape', selectedShape);
      var colorItem = findFullItem('color', selectedColor);
      var finishItem = findFullItem('finish', selectedFinish);
      var accessoryItem = findFullItem('accessory', selectedAccessory);

      int pShape = int.tryParse(shapeItem?['price'].toString() ?? '0') ?? 0;
      int pColor = int.tryParse(colorItem?['price'].toString() ?? '0') ?? 0;
      int pFinish = int.tryParse(finishItem?['price'].toString() ?? '0') ?? 0;
      int pAccessory =
          int.tryParse(accessoryItem?['price'].toString() ?? '0') ?? 0;
      int basePrice =
          int.tryParse(widget.reservation?['total_price'].toString() ?? '') ??
              int.tryParse(widget.reservation?['price'].toString() ?? '0') ??
              0;

      int grandTotal = basePrice + pShape + pColor + pFinish + pAccessory;

      setState(() {
        _loading = false;
        _generationCount++;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AIResultScreen(
            token: widget.token,
            user: widget.user,
            imageUrl: finalImageUrl,
            shape: selectedShape,
            color: selectedColor,
            finish: selectedFinish,
            accessory: selectedAccessory,
            priceShape: pShape,
            priceColor: pColor,
            priceFinish: pFinish,
            priceAccessory: pAccessory,
            totalPrice: grandTotal,
            reservation: widget.reservation,
          ),
        ),
      );
    } else {
      String msg = result['message'] ?? "Unknown error occurred";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(msg)),
      );
      setState(() => _loading = false);
    }
  }

  void _nextPage() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  Widget _buildStepPage({
    required String title,
    required String subtitle,
    required List<dynamic> items,
    required String? selectedValue,
    required Function(String) onSelect,
    VoidCallback? onSkip,
    bool disabled = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF451A2B),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              if (onSkip != null)
                TextButton(
                  onPressed: onSkip,
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF975B73),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text("No items available"))
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item['name'] == selectedValue;
                    final imageUrl = item['image'] != null
                        ? "${ApiService.baseUrl}/served-image/${item['image']}"
                        : null;

                    return GestureDetector(
                      onTap: disabled
                          ? null
                          : () {
                              onSelect(item['name']);
                              _nextPage();
                            },
                      child: Opacity(
                        opacity: disabled ? 0.5 : 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF975B73)
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(17)),
                                  child: imageUrl != null
                                      ? Image.network(
                                          imageUrl,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[100],
                                              child: const Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey),
                                            );
                                          },
                                        )
                                      : Container(
                                          color: Colors.grey[100],
                                          child: const Center(
                                            child: Icon(Icons.image,
                                                color: Colors.grey, size: 40),
                                          ),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? '-',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: isSelected
                                            ? const Color(0xFF975B73)
                                            : const Color(0xFF451A2B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatRupiah(item['price']),
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        color: Color(0xFFAF7C85),
                                        fontWeight: FontWeight.w500,
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
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryPage() {
    var shapeItem = findFullItem('shape', selectedShape);
    var colorItem = findFullItem('color', selectedColor);
    var finishItem = findFullItem('finish', selectedFinish);
    var accessoryItem = findFullItem('accessory', selectedAccessory);

    int pShape = int.tryParse(shapeItem?['price'].toString() ?? '0') ?? 0;
    int pColor = int.tryParse(colorItem?['price'].toString() ?? '0') ?? 0;
    int pFinish = int.tryParse(finishItem?['price'].toString() ?? '0') ?? 0;
    int pAccessory =
        int.tryParse(accessoryItem?['price'].toString() ?? '0') ?? 0;
    int basePrice =
        int.tryParse(widget.reservation?['total_price'].toString() ?? '') ??
            int.tryParse(widget.reservation?['price'].toString() ?? '0') ??
            0;

    int grandTotal = basePrice + pShape + pColor + pFinish + pAccessory;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Summary",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF451A2B),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Review your design choices.",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5C1C8)),
            ),
            child: Text(
              "Attempts remaining: ${_maxGenerations - _generationCount}",
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF975B73),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSummaryItem("Shape", selectedShape, pShape),
                    const Divider(),
                    _buildSummaryItem("Color", selectedColor, pColor),
                    const Divider(),
                    _buildSummaryItem("Finish", selectedFinish, pFinish),
                    const Divider(),
                    _buildSummaryItem(
                        "Accessory", selectedAccessory, pAccessory),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _loading ? null : generateImage,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: _loading
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFFAF7C85), Color(0xFF975B73)],
                      ),
                color: _loading ? Colors.grey[300] : null,
                borderRadius: BorderRadius.circular(20),
                boxShadow: _loading
                    ? []
                    : [
                        BoxShadow(
                          color: const Color(0xFF975B73).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: _loading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : const Text(
                      "Generate Design",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 15),
          // SKIP AI BUTTON
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _loading ? null : _confirmCustomSelection,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFF975B73), width: 1.5),
                ),
              ),
              child: const Text(
                "Add Items Only (Skip AI)",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF975B73),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCustomSelection() async {
    if (widget.reservation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No active reservation found.")),
      );
      return;
    }

    var shapeItem = findFullItem('shape', selectedShape);
    var colorItem = findFullItem('color', selectedColor);
    var finishItem = findFullItem('finish', selectedFinish);
    var accessoryItem = findFullItem('accessory', selectedAccessory);

    int pShape = int.tryParse(shapeItem?['price'].toString() ?? '0') ?? 0;
    int pColor = int.tryParse(colorItem?['price'].toString() ?? '0') ?? 0;
    int pFinish = int.tryParse(finishItem?['price'].toString() ?? '0') ?? 0;
    int pAccessory =
        int.tryParse(accessoryItem?['price'].toString() ?? '0') ?? 0;

    int customDesignPrice = pShape + pColor + pFinish + pAccessory;

    if (customDesignPrice == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No items selected to add.")),
      );
      return;
    }

    int currentTotal =
        int.tryParse(widget.reservation!['total_price'].toString()) ??
            int.tryParse(widget.reservation!['price'].toString()) ??
            0;

    int newTotal = currentTotal + customDesignPrice;

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
          title: const Text("Items Added!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("The selected items have been added to the bill."),
              const SizedBox(height: 10),
              const Divider(),
              if (selectedShape != null) Text("Shape: $selectedShape"),
              if (selectedColor != null) Text("Color: $selectedColor"),
              if (selectedFinish != null) Text("Finish: $selectedFinish"),
              if (selectedAccessory != null)
                Text("Accessory: $selectedAccessory"),
              const SizedBox(height: 5),
              Text("Added Cost: ${formatRupiah(customDesignPrice)}"),
              const Divider(),
              Text(
                "New Total Bill: ${formatRupiah(newTotal)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close dialog
                // Optionally navigate back to dashboard
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

  Widget _buildSummaryItem(String label, String? value, int price) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value ?? "-",
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF451A2B),
                ),
              ),
              if (price > 0)
                Text(
                  formatRupiah(price),
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 12,
                    color: Color(0xFFAF7C85),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String formatRupiah(dynamic price) {
    int priceInt = int.tryParse(price.toString()) ?? 0;
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(priceInt);
  }

  @override
  Widget build(BuildContext context) {
    final isExtension =
        widget.reservation?["treatment_type"] == "nail_extension";

    return Column(
      children: [
        // Progress Indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: const Color(0xFFFFF1F3),
          child: Row(
            children: [
              if (_currentStep > 0)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 20, color: Color(0xFF451A2B)),
                  onPressed: _prevPage,
                ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / 5,
                    backgroundColor: Colors.white,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF975B73)),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Step ${_currentStep + 1}/5",
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF975B73),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Disable swipe
            children: [
              // STEP 1: SHAPE
              _buildStepPage(
                title: "Choose Shape",
                subtitle: "Select the shape of your nails.",
                items: categories["shape"] ?? [],
                selectedValue: selectedShape,
                onSelect: (val) => setState(() => selectedShape = val),
                onSkip: () {
                  setState(() => selectedShape = null);
                  _nextPage();
                },
                disabled: !isExtension,
              ),
              // STEP 2: COLOR
              _buildStepPage(
                title: "Choose Color",
                subtitle: "Select the base color.",
                items: categories["color"] ?? [],
                selectedValue: selectedColor,
                onSelect: (val) => setState(() => selectedColor = val),
                onSkip: () {
                  setState(() => selectedColor = null);
                  _nextPage();
                },
              ),
              // STEP 3: FINISH
              _buildStepPage(
                title: "Choose Finish",
                subtitle: "Select the finish texture.",
                items: categories["finish"] ?? [],
                selectedValue: selectedFinish,
                onSelect: (val) => setState(() => selectedFinish = val),
                onSkip: () {
                  setState(() => selectedFinish = null);
                  _nextPage();
                },
              ),
              // STEP 4: ACCESSORY
              _buildStepPage(
                title: "Choose Accessory",
                subtitle: "Select an accessory (optional).",
                items: categories["accessory"] ?? [],
                selectedValue: selectedAccessory,
                onSelect: (val) => setState(() => selectedAccessory = val),
                onSkip: () {
                  setState(() => selectedAccessory = null);
                  _nextPage();
                },
              ),
              // STEP 5: SUMMARY
              _buildSummaryPage(),
            ],
          ),
        ),
      ],
    );
  }
}

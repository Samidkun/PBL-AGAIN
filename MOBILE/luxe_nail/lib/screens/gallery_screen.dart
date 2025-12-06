import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luxe_nail/services/api_service.dart';
import 'package:luxe_nail/screens/ai_result_screen.dart';
import 'package:luxe_nail/widgets/gallery/gallery_drawer.dart';
import 'package:luxe_nail/widgets/gallery/selection_grid.dart';
import 'package:luxe_nail/widgets/gallery/template_details_modal.dart';
import 'package:luxe_nail/widgets/gallery/templates_tab.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  Map<String, dynamic> categories = {
    "nail_shape": [],
    "nail_type": [],
    "color": [],
    "shape": [],
    "finish": [],
    "accessory": [],
  };

  String? selectedCategoryFilter;
  String selectedTypeFilter = "all"; // Filter untuk Nail Art / Extension
  int _generationCount = 0;
  final int _maxGenerations = 3;

  @override
  void initState() {
    super.initState();
    if (widget.reservation != null) {
      _generationCount = widget.reservation!['generate_count'] ?? 0;
    }
    _fetchCatalog();
  }

  // ================== JOB FINISH ==================
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

  // ================== FETCH CATALOG ==================
  // ================== FETCH CATALOG ==================
  Future<void> _fetchCatalog() async {
    print("DEBUG: _fetchCatalog started");
    try {
      final result = await ApiService.getCategories(widget.token);
      print("DEBUG: ApiService returned: $result");

      if (!mounted) {
        print("DEBUG: Widget not mounted, aborting");
        return;
      }

      if (result['success']) {
        final dynamic data = result['data'];
        print("DEBUG: Data received: $data (Type: ${data.runtimeType})");

        Map<String, dynamic> safeData = {};
        if (data is Map<String, dynamic>) {
          safeData = data;
        } else if (data is List && data.isEmpty) {
          print("DEBUG: Data is empty list, treating as empty map");
          safeData = {};
        } else {
          print("DEBUG: Unexpected data format");
        }

        // Filter categories based on reservation type if available
        String? reservationType;
        if (widget.reservation != null) {
          print("DEBUG: Reservation Data: ${widget.reservation}");
          reservationType = widget.reservation!['treatment_type'] ??
              widget.reservation!['service_type'] ??
              widget.reservation!['type'];
          print("DEBUG: Reservation Type detected: $reservationType");
        }

        List<Map<String, dynamic>> filterItems(List<dynamic> items) {
          if (reservationType == null)
            return List<Map<String, dynamic>>.from(items);

          return List<Map<String, dynamic>>.from(items).where((item) {
            final itemTreatmentType = item['treatment_type'];
            if (itemTreatmentType == null) return true;

            String rType =
                reservationType!.toString().toLowerCase().replaceAll('_', ' ');
            String iType =
                itemTreatmentType.toString().toLowerCase().replaceAll('_', ' ');

            return iType == rType;
          }).toList();
        }

        setState(() {
          categories = {
            'nail_shape': filterItems(safeData['shape'] ?? []),
            'nail_type': filterItems(safeData['finish'] ?? []),
            'color': filterItems(safeData['color'] ?? []),
            'accessory': filterItems(safeData['accessory'] ?? []),
          };
          _isLoading = false;
        });
        print("DEBUG: State updated with filtered categories");
      } else {
        print("DEBUG: API success = false");
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Failed to load catalog: ${result['message']}")),
          );
        }
      }
    } catch (e, stackTrace) {
      print("DEBUG: Error in _fetchCatalog: $e");
      print("DEBUG: Stack trace: $stackTrace");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading catalog: $e")),
        );
      }
    }
  }

  // ================== HELPERS ==================
  String formatRupiah(dynamic price) {
    int priceInt = int.tryParse(price.toString()) ?? 0;
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(priceInt);
  }

  // ================== BUILD ==================
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
            _buildTemplatesTab(),
            _buildCustomDesignCatalogTab(),
          ],
        ),
      ),
    );
  }

  // ================== DRAWER ==================
  Widget _buildDrawer() {
    return GalleryDrawer(
      token: widget.token,
      user: widget.user,
    );
  }

  // ================== TEMPLATES TAB ==================
  Widget _buildTemplatesTab() {
    return TemplatesTab(
      onTemplateSelect: _showTemplateDetails,
    );
  }

  void _showTemplateDetails(Map<String, dynamic> template) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => TemplateDetailsModal(
        template: template,
        onConfirm: () => _confirmSelection(template),
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

    // Calculate prices
    int currentTotal =
        int.tryParse(widget.reservation!['total_price'].toString()) ?? 0;
    int templatePrice = int.tryParse(template['price'].toString()) ?? 0;
    int newTotal = currentTotal + templatePrice;

    // Navigate to AIResultScreen for processing (same as custom design)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AIResultScreen(
          token: widget.token,
          user: widget.user,
          imageUrl: template['image'], // Use template image
          shape: template['shape'],
          color: template['color'],
          finish: template['finish'],
          accessory: template['accessory'],
          priceShape: 0,
          priceColor: 0,
          priceFinish: 0,
          priceAccessory: templatePrice, // All price in accessory
          totalPrice: newTotal,
          reservation: widget.reservation,
        ),
      ),
    );
  }

  // ================== AI GENERATION ==================
  Future<void> _generateAiImage() async {
    if (_selectedShape == null ||
        _selectedType == null ||
        _selectedColor == null ||
        _selectedAccessory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select all items first.")),
      );
      return;
    }

    if (_generationCount >= _maxGenerations) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Limit reached: You can only generate 3 designs.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Build Prompt
    String prompt = "Macro photo, professional nail art design. ";
    prompt += "Shape: ${_selectedShape!['name']}. ";
    prompt += "Type: ${_selectedType!['name']}. ";
    prompt += "Color: ${_selectedColor!['name']}. ";
    prompt += "Accessory: ${_selectedAccessory!['name']}. ";
    prompt += "Photorealistic, high detail, 8k, cinematic lighting, elegant.";

    print("DEBUG: Generating AI Image with prompt: $prompt");

    try {
      final result = await ApiService.generateAIImage(
          widget.token, prompt, widget.reservation?['id']);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        // Increment Count
        await ApiService.incrementGenerate(
            widget.token, widget.reservation!['id']);
        setState(() => _generationCount++);

        final imageUrl = result['image_url'];

        // Calculate Prices
        int priceShape = int.tryParse(_selectedShape!['price'].toString()) ?? 0;
        int priceType = int.tryParse(_selectedType!['price'].toString()) ?? 0;
        int priceColor = int.tryParse(_selectedColor!['price'].toString()) ?? 0;
        int priceAccessory =
            int.tryParse(_selectedAccessory!['price'].toString()) ?? 0;

        int totalPrice = priceShape + priceType + priceColor + priceAccessory;

        print("DEBUG: Navigating to AIResultScreen");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AIResultScreen(
              token: widget.token,
              user: widget.user,
              imageUrl: imageUrl,
              totalPrice: totalPrice,
              priceShape: priceShape,
              priceFinish: priceType, // Mapping Type to Finish
              priceColor: priceColor,
              priceAccessory: priceAccessory,
              shape: _selectedShape!['name'],
              finish: _selectedType!['name'],
              color: _selectedColor!['name'],
              accessory: _selectedAccessory!['name'],
              reservation: widget.reservation,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? "Generation failed")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  // ================== CUSTOM DESIGN TAB ==================
  // ================== CUSTOM DESIGN WIZARD STATE ==================
  // ================== CUSTOM DESIGN TAB ==================
  // ================== CUSTOM DESIGN WIZARD STATE ==================
  final PageController _pageController = PageController();
  int _customDesignStep = 0;
  Map<String, dynamic>? _selectedShape;
  Map<String, dynamic>? _selectedType;
  Map<String, dynamic>? _selectedColor;
  Map<String, dynamic>? _selectedAccessory;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ================== CUSTOM DESIGN WIZARD UI ==================
  Widget _buildCustomDesignCatalogTab() {
    // Ensure categories are loaded
    final shapes = categories['nail_shape'] ?? [];
    final types = categories['nail_type'] ?? [];
    final colors = categories['color'] ?? [];
    final accessories = categories['accessory'] ?? [];

    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFAF7C85)));
    }

    // Sync PageView with State
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != _customDesignStep) {
        _pageController.jumpToPage(_customDesignStep);
      }
    });

    return Column(
      children: [
        // Wizard Header (Step Indicator)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepIndicator(0, "Shape"),
              _buildStepLine(0),
              _buildStepIndicator(1, "Type"),
              _buildStepLine(1),
              _buildStepIndicator(2, "Color"),
              _buildStepLine(2),
              _buildStepIndicator(3, "Accessory"),
            ],
          ),
        ),

        Expanded(
          child: PageView(
            controller: _pageController,
            physics:
                const NeverScrollableScrollPhysics(), // Disable swipe, force selection
            onPageChanged: (index) {
              setState(() {
                _customDesignStep = index;
              });
            },
            children: [
              // STEP 1: SHAPE
              _buildSelectionGrid(
                items: shapes,
                selectedItem: _selectedShape,
                onSelect: (item) {
                  setState(() => _selectedShape = item);
                  _autoSlideToNext(1);
                },
                title: "Choose Nail Shape",
              ),

              // STEP 2: TYPE
              _buildSelectionGrid(
                items: types,
                selectedItem: _selectedType,
                onSelect: (item) {
                  setState(() => _selectedType = item);
                  _autoSlideToNext(2);
                },
                title: "Choose Nail Type",
              ),

              // STEP 3: COLOR
              _buildSelectionGrid(
                items: colors,
                selectedItem: _selectedColor,
                onSelect: (item) {
                  setState(() => _selectedColor = item);
                  _autoSlideToNext(3);
                },
                title: "Choose Nail Color",
              ),

              // STEP 4: ACCESSORY
              _buildSelectionGrid(
                items: accessories,
                selectedItem: _selectedAccessory,
                onSelect: (item) {
                  setState(() => _selectedAccessory = item);
                },
                title: "Choose Accessory",
              ),
            ],
          ),
        ),

        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              // BACK BUTTON
              if (_customDesignStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _goToPreviousStep,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF975B73)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Back",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF975B73),
                      ),
                    ),
                  ),
                ),

              if (_customDesignStep > 0) const SizedBox(width: 16),

              // ... (inside _buildCustomDesignCatalogTab)

              // FINISH BUTTON (Only on last step)
              if (_customDesignStep == 3 && _selectedAccessory != null)
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed:
                        _generateAiImage, // Changed from _navigateToFinishing
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF975B73),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Generate & Finish",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 14, // Slightly smaller to fit
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.auto_awesome, color: Colors.white),
                            ],
                          ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _autoSlideToNext(int nextStep) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextStep,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _goToPreviousStep() {
    if (_customDesignStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildStepIndicator(int step, String label) {
    bool isActive = _customDesignStep >= step;
    bool isCurrent = _customDesignStep == step;

    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF975B73) : Colors.grey[300],
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: const Color(0xFFAF7C85), width: 2)
                : null,
          ),
          child: Center(
            child: isActive
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    "${step + 1}",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? const Color(0xFF975B73) : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    bool isActive = _customDesignStep > step;
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? const Color(0xFF975B73) : Colors.grey[300],
      ),
    );
  }

  Widget _buildSelectionGrid({
    required List<dynamic> items,
    required Map<String, dynamic>? selectedItem,
    required Function(Map<String, dynamic>) onSelect,
    required String title,
  }) {
    return SelectionGrid(
      items: items,
      selectedItem: selectedItem,
      onSelect: onSelect,
      title: title,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luxe_nail/services/api_service.dart';
import 'package:luxe_nail/screens/processing_screen.dart';

class AIResultScreen extends StatefulWidget {
  final String token;
  final String imageUrl;
  final Map<String, dynamic> user;

  final String? shape;
  final String? color;
  final String? finish;
  final String? accessory;

  final int priceShape;
  final int priceColor;
  final int priceFinish;
  final int priceAccessory;

  final int totalPrice;

  final Map<String, dynamic>? reservation;

  const AIResultScreen({
    super.key,
    required this.token,
    required this.imageUrl,
    required this.user,
    required this.totalPrice,
    required this.priceShape,
    required this.priceColor,
    required this.priceFinish,
    required this.priceAccessory,
    this.shape,
    this.color,
    this.finish,
    this.accessory,
    this.reservation,
  });

  @override
  State<AIResultScreen> createState() => _AIResultScreenState();
}

class _AIResultScreenState extends State<AIResultScreen> {
  String formatRupiah(dynamic price) {
    int priceInt = int.tryParse(price.toString()) ?? 0;
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(priceInt);
  }

  Widget _sectionTitle(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: "Poppins",
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF451A2B),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: "Poppins")),
          Text(
            value,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w600,
              color: Color(0xFF975B73),
            ),
          ),
        ],
      ),
    );
  }

  Widget _container(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEAEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFEAEE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF451A2B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "AI Result",
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w600,
            color: Color(0xFF451A2B),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ---------- AI IMAGE ----------
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.white,
                    child: const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFAF7C85)),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Center(
                        child: Text("Gagal memuat gambar",
                            style: TextStyle(color: Colors.red))),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // ---------- CUSTOMER INFO ----------
            _container(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Customer Information"),
                  _infoRow("Name", widget.reservation?["name"] ?? "-"),
                  _infoRow("Phone", widget.reservation?["phone"] ?? "-"),
                  _infoRow("Address", widget.reservation?["address"] ?? "-"),
                ],
              ),
            ),

            // ---------- PRICING ----------
            _container(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Pricing Details"),
                  if ((widget.totalPrice -
                          (widget.priceShape +
                              widget.priceColor +
                              widget.priceFinish +
                              widget.priceAccessory)) >
                      0)
                    _infoRow(
                        "Previous Bill",
                        formatRupiah(widget.totalPrice -
                            (widget.priceShape +
                                widget.priceColor +
                                widget.priceFinish +
                                widget.priceAccessory))),
                  _infoRow(
                      "Shape (${widget.shape ?? '-'})",
                      widget.priceShape > 0
                          ? formatRupiah(widget.priceShape)
                          : "-"),
                  _infoRow(
                      "Color (${widget.color ?? '-'})",
                      widget.priceColor > 0
                          ? formatRupiah(widget.priceColor)
                          : "-"),
                  _infoRow(
                      "Finish (${widget.finish ?? '-'})",
                      widget.priceFinish > 0
                          ? formatRupiah(widget.priceFinish)
                          : "-"),
                  _infoRow(
                      "Accessory (${widget.accessory ?? '-'})",
                      widget.priceAccessory > 0
                          ? formatRupiah(widget.priceAccessory)
                          : "-"),
                  const Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Price",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF451A2B),
                        ),
                      ),
                      Text(
                        formatRupiah(widget.totalPrice),
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Color(0xFFAF7C85),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ---------- USE THIS DESIGN (ADD-ON LOGIC) ----------
            if (widget.reservation != null)
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF975B73),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _confirmDesign,
                  child: const Text(
                    "Use This Design (Add to Bill)",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDesign() async {
    if (widget.reservation == null) return;

    // Use widget.totalPrice which already includes Base + Design
    int newTotal = widget.totalPrice;

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
        // We could also save image_url here if backend supports it
      },
    );

    if (!mounted) return;
    Navigator.pop(context); // Close loading

    if (result['success']) {
      // AUTO-FINISH: Mark as waiting_payment immediately
      // await ApiService.finishJob(widget.token, widget.reservation!['id']);

      // Navigate to Processing Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProcessingScreen(
            token: widget.token,
            user: widget.user,
            reservation: widget.reservation!,
            totalPrice: newTotal,
            imageUrl: widget.imageUrl,
            shape: widget.shape,
            color: widget.color,
            finish: widget.finish,
            accessory: widget.accessory,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Failed to update bill")),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luxe_nail/services/api_service.dart';
import 'package:luxe_nail/screens/dashboard_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;
  final Map<String, dynamic> reservation;
  final int totalPrice;

  final String? imageUrl;
  final String? shape;
  final String? color;
  final String? finish;
  final String? accessory;

  const ProcessingScreen({
    super.key,
    required this.token,
    required this.user,
    required this.reservation,
    required this.totalPrice,
    this.imageUrl,
    this.shape,
    this.color,
    this.finish,
    this.accessory,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  bool _isLoading = false;

  String formatRupiah(dynamic price) {
    int priceInt = int.tryParse(price.toString()) ?? 0;
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(priceInt);
  }

  Future<void> _finishJob() async {
    setState(() => _isLoading = true);

    final result =
        await ApiService.finishJob(widget.token, widget.reservation['id']);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Job Completed!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("The reservation has been marked as finished."),
              const SizedBox(height: 10),
              const Text(
                "Please direct the customer to the cashier for payment.",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                // Navigate back to Dashboard and remove all previous routes
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => DashboardScreen(
                      token: widget.token,
                      user: widget.user,
                    ),
                  ),
                  (route) => false,
                );
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Failed to finish job")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F3),
      appBar: AppBar(
        title: const Text(
          "Processing",
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
            color: Color(0xFF451A2B),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFF1F3),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.brush_rounded,
                      size: 50, color: Color(0xFF975B73)),
                  const SizedBox(height: 10),
                  const Text(
                    "Nail Art in Progress",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF451A2B),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Customer: ${widget.reservation['name'] ?? 'Guest'}",
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 16,
                      color: Color(0xFFAF7C85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Reference Image (if available)
            if (widget.imageUrl != null)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Builder(
                    builder: (context) {
                      // Debug: Print image URL
                      print('🖼️ Loading image from: ${widget.imageUrl}');

                      // Check if it's an asset or network image
                      final isAsset = widget.imageUrl!.startsWith('assets/') ||
                          widget.imageUrl!.contains('file:///assets/');

                      if (isAsset) {
                        // Extract asset path (remove file:/// prefix if present)
                        final assetPath = widget.imageUrl!
                            .replaceAll('file:///', '')
                            .replaceAll('file://', '');

                        print('📁 Loading as asset: $assetPath');

                        return Image.asset(
                          assetPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('❌ Asset load failed: $error');
                            return Container(
                              color: Colors.red[50],
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Failed to load image',
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }

                      // Network image
                      print('🌐 Loading as network image');
                      return Image.network(
                        widget.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            print('✅ Image loaded successfully');
                            return child;
                          }

                          return Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF975B73),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('❌ Network image load failed: $error');
                          return Container(
                            color: Colors.red[50],
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 40,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Failed to load image',
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  error.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

            // Design Details
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5C1C8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Design Specifications",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF451A2B),
                    ),
                  ),
                  const Divider(height: 20),
                  _buildDetailRow("Shape", widget.shape),
                  _buildDetailRow("Color", widget.color),
                  _buildDetailRow("Finish", widget.finish),
                  _buildDetailRow("Accessory", widget.accessory),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bill Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF975B73),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Bill",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    formatRupiah(widget.totalPrice),
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Done Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _finishJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF451A2B),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Done (Finish Job)",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 18,
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
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: "Poppins",
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value ?? "-",
            style: const TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w600,
              color: Color(0xFF451A2B),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

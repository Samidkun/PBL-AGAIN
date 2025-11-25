import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // PERLU PACKAGE intl

class AIResultScreen extends StatelessWidget {
  // === VARIABEL TAMBAHAN UNTUK API CALL ===
  final String token; 
  final String imageUrl; 

  final String? shape;
  final String? color;
  final String? finish;
  final String? accessory;

  final int priceShape;
  final int priceColor;
  final int priceFinish;
  final int priceAccessory;

  final int totalPrice; // Ini adalah Total Harga Addons + Base Price

  final Map<String, dynamic>? reservation;

  const AIResultScreen({
    super.key,
    required this.token, // WAJIB DIKIRIM DARI AIScreen.dart
    required this.imageUrl, 
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

  // ---------- UI & API HELPERS ----------
  String formatRupiah(dynamic price) {
    int priceInt = int.tryParse(price.toString()) ?? 0;
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
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
  
  // ==========================================================
  // FUNGSI KONFIRMASI PEMBAYARAN (BARU)
  // ==========================================================
  Future<void> confirmPayment(BuildContext context) async {
    final baseUrl = dotenv.env['BASE_URL'];
    
    if (reservation == null || baseUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: Reservation or Base URL missing.")));
        return;
    }

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/income/store"), // <-- ENDPOINT DI LARAVEL
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode({
          // Kunci harus match dengan validasi di IncomeController.php store()
          'reservation_id': reservation!['id'], 
          
          'shape': shape,
          'color': color,
          'finish': finish,
          'accessory': accessory,
          
          'price_shape': priceShape,
          'price_color': priceColor,
          'price_finish': priceFinish,
          'price_accessory': priceAccessory,
          
          'total_price': totalPrice, // Total harga untuk disimpan
          
          'ai_image_url': imageUrl, // URL gambar hasil generate
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text("Pembayaran berhasil dicatat!")),
        );
        // Kembali ke layar sebelumnya (AIScreen) atau ke dashboard utama
        Navigator.popUntil(context, (route) => route.isFirst); 

      } else {
        String errorMsg = data['message'] ?? "Gagal mencatat pembayaran.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text("Error: $errorMsg")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text("Koneksi gagal: $e")),
      );
    }
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

      // BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ---------- AI IMAGE (URL) ----------
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl, 
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFFAF7C85)),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Center(child: Text("Gagal memuat gambar", style: TextStyle(color: Colors.red))),
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
                  _infoRow("Name", reservation?["name"] ?? "-"),
                  _infoRow("Phone", reservation?["phone"] ?? "-"),
                  _infoRow("Address", reservation?["address"] ?? "-"),
                ],
              ),
            ),

            // ---------- RESERVATION INFO ----------
            _container(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Reservation Info"),
                  _infoRow(
                    "Treatment Type",
                    (reservation?["treatment_type"] == "nail_extension")
                        ? "Nail Extension"
                        : "Nail Art",
                  ),
                  _infoRow("Queue Number",
                      reservation?["queue_number"]?.toString() ?? "-"),
                  _infoRow("Date", reservation?["reservation_date"] ?? "-"),
                  _infoRow("Time", reservation?["reservation_time"] ?? "-"),
                ],
              ),
            ),

            // ---------- DESIGN DETAILS ----------
            _container(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Nail Design Details"),
                  _infoRow("Shape", shape ?? "-"),
                  _infoRow("Color", color ?? "-"),
                  _infoRow("Finish", finish ?? "-"),
                  _infoRow("Accessory", accessory ?? "-"),
                ],
              ),
            ),

            // ---------- PRICING ----------
            _container(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Pricing"),

                  _infoRow("Shape", priceShape > 0 ? formatRupiah(priceShape) : "-"),
                  _infoRow("Color", priceColor > 0 ? formatRupiah(priceColor) : "-"),
                  _infoRow("Finish", priceFinish > 0 ? formatRupiah(priceFinish) : "-"),
                  _infoRow("Accessory", priceAccessory > 0 ? formatRupiah(priceAccessory) : "-"),

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
                        formatRupiah(totalPrice),
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

            const SizedBox(height: 20),

            // ---------- KONFIRMASI BUTTON ----------
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAF7C85),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => confirmPayment(context), // PANGGIL FUNGSI PAYMENT BARU
              child: const Text(
                "Confirm Design & Payment",
                style: TextStyle(
                  fontFamily: "Poppins",
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
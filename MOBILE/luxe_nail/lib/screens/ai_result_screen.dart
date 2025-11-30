import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luxe_nail/services/api_service.dart';
import 'package:luxe_nail/screens/thankyou_screen.dart';

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
  final TextEditingController _cashController = TextEditingController();
  int _cashAmount = 0;
  int _changeAmount = 0;
  String? _errorMessage;
  String _selectedPaymentMethod = 'cash'; // 'cash' or 'transfer'

  @override
  void initState() {
    super.initState();
    _cashController.addListener(_calculateChange);
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  void _calculateChange() {
    String text = _cashController.text.replaceAll(RegExp(r'[^0-9]'), '');
    int cash = int.tryParse(text) ?? 0;

    setState(() {
      _cashAmount = cash;
      _changeAmount = cash - widget.totalPrice;

      if (cash > 0 && cash < widget.totalPrice) {
        _errorMessage = "Insufficient cash";
      } else {
        _errorMessage = null;
      }
    });
  }

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

  Future<void> confirmPayment() async {
    if (widget.reservation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Reservation missing.")));
      return;
    }

    if (_selectedPaymentMethod == 'cash' && _cashAmount < widget.totalPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Insufficient cash amount!")),
      );
      return;
    }

    final paymentData = {
      'reservation_id': widget.reservation!['id'],
      'shape': widget.shape,
      'color': widget.color,
      'finish': widget.finish,
      'accessory': widget.accessory,
      'price_shape': widget.priceShape,
      'price_color': widget.priceColor,
      'price_finish': widget.priceFinish,
      'price_accessory': widget.priceAccessory,
      'total_price': widget.totalPrice,
      'ai_image_url': widget.imageUrl,
      'payment_method': _selectedPaymentMethod,
      'cash_amount': _selectedPaymentMethod == 'cash' ? _cashAmount : 0,
      'change_amount': _selectedPaymentMethod == 'cash' ? _changeAmount : 0,
    };

    final result = await ApiService.confirmPayment(widget.token, paymentData);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Pembayaran berhasil dicatat!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ThankYouScreen(token: widget.token, user: widget.user)),
      );
    } else {
      String errorMsg = result['message'] ?? "Gagal mencatat pembayaran.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red, content: Text("Error: $errorMsg")),
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
          "AI Result & Payment",
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

            // ---------- PAYMENT METHOD SELECTION ----------
            _container(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Payment Method"),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Cash",
                              style: TextStyle(fontFamily: "Poppins")),
                          value: 'cash',
                          groupValue: _selectedPaymentMethod,
                          activeColor: const Color(0xFFAF7C85),
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Transfer",
                              style: TextStyle(fontFamily: "Poppins")),
                          value: 'transfer',
                          groupValue: _selectedPaymentMethod,
                          activeColor: const Color(0xFFAF7C85),
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ---------- CASHIER CALCULATOR (ONLY IF CASH) ----------
            if (_selectedPaymentMethod == 'cash')
              _container(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Cashier Calculator"),
                    const SizedBox(height: 10),

                    // INPUT CASH
                    TextField(
                      controller: _cashController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Cash Received (Rp)",
                        prefixText: "Rp ",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorText: _errorMessage,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // CHANGE DISPLAY
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Change (Kembalian)",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF451A2B),
                          ),
                        ),
                        Text(
                          formatRupiah(_changeAmount > 0 ? _changeAmount : 0),
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color:
                                _changeAmount >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // ---------- BANK DETAILS (ONLY IF TRANSFER) ----------
            if (_selectedPaymentMethod == 'transfer')
              _container(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Bank Transfer Details"),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.account_balance,
                                  color: Color(0xFF451A2B), size: 30),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Bank BCA",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Poppins")),
                                  Text("123 456 7890",
                                      style: TextStyle(
                                          fontFamily: "Poppins", fontSize: 16)),
                                  Text("a.n Luxe Nail Art",
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 12,
                                          color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Please transfer the exact amount and show the proof to the cashier.",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            // ---------- CONFIRM BUTTON ----------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAF7C85),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: (_selectedPaymentMethod == 'transfer' ||
                        _cashAmount >= widget.totalPrice)
                    ? confirmPayment
                    : null,
                child: const Text(
                  "Confirm Payment",
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
}

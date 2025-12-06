import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luxe_nail/screens/gallery_screen.dart';
import 'package:luxe_nail/screens/history_screen.dart';
import 'package:luxe_nail/services/api_service.dart';
import 'package:luxe_nail/widgets/dashboard/dashboard_drawer.dart';
import 'package:luxe_nail/widgets/dashboard/reservation_card.dart';

class DashboardScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;

  const DashboardScreen({super.key, required this.token, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // State variables
  List<dynamic> reservations = [];
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();
  bool isOnBreak = false;
  Timer? _pollingTimer; // Auto-refresh timer

  @override
  void initState() {
    super.initState();
    _fetchReservations();
    // Start polling every 10 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _fetchReservations();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // Stop polling when leaving screen
    super.dispose();
  }

  Future<void> _fetchReservations() async {
    setState(() => isLoading = true);

    // Format date for API
    String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    final result =
        await ApiService.getReservations(widget.token, date: dateStr);

    if (!mounted) return;

    setState(() {
      isLoading = false;
      if (result['success']) {
        // Filter out completed and cancelled reservations
        reservations = (result['data'] as List).where((r) {
          String status = (r['status'] ?? '').toString().toLowerCase();
          return status != 'completed' &&
              status != 'cancelled' &&
              status != 'waiting_payment';
        }).toList();
      } else {
        reservations = [];
        // Optional: Show error snackbar
      }
    });
  }

  Future<void> _toggleBreak() async {
    final result = await ApiService.toggleBreak(widget.token);
    if (!mounted) return;
    if (result['success']) {
      setState(() {
        isOnBreak = result['is_on_break'] ??
            !isOnBreak; // Fallback if api doesn't return key
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFAF7C85),
              onPrimary: Colors.white,
              onSurface: Color(0xFF451A2B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _fetchReservations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F3),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          const SizedBox(height: 60),
          _buildHeader(),
          const SizedBox(height: 20),
          _buildDateSelector(),
          const SizedBox(height: 20),
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
              child: isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFAF7C85)))
                  : reservations.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: reservations.length,
                          itemBuilder: (context, index) {
                            return _reservationCard(reservations[index]);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return DashboardDrawer(
      token: widget.token,
      user: widget.user,
      isOnBreak: isOnBreak,
      onToggleBreak: _toggleBreak,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: const Icon(Icons.menu, size: 28, color: Color(0xFF451A2B)),
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
          // History Icon
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      HistoryScreen(token: widget.token, user: widget.user),
                ),
              );
            },
            child:
                const Icon(Icons.history, size: 28, color: Color(0xFF451A2B)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Today's Appointments",
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF451A2B))),
              Text(DateFormat('EEEE, d MMMM y').format(selectedDate),
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFF975B73))),
            ],
          ),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]),
              child: const Icon(Icons.calendar_today_rounded,
                  color: Color(0xFFAF7C85), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No appointments found",
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _reservationCard(Map<String, dynamic> reservation) {
    return ReservationCard(
      reservation: reservation,
      onTap: () async {
        // CHECK DATE: Only allow processing for today's reservations
        String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        String resDate = reservation['reservation_date'] ?? '';

        if (resDate != todayStr) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "You can only process reservations scheduled for today."),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // Navigate to GalleryScreen with reservation data
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GalleryScreen(
              token: widget.token,
              user: widget.user,
              reservation: reservation,
            ),
          ),
        );

        // If result is true (job finished), refresh list
        if (result == true) {
          _fetchReservations();
        }
      },
    );
  }
}

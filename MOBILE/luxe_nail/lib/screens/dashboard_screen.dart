import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luxe_nail/screens/gallery_screen.dart';
import 'package:luxe_nail/screens/history_screen.dart';
import 'package:luxe_nail/screens/login_screen.dart';
import 'package:luxe_nail/screens/profile_screen.dart';
import 'package:luxe_nail/services/api_service.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchReservations();
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
          return status != 'completed' && status != 'cancelled';
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
    return Drawer(
      backgroundColor: const Color(0xFFFFF8F9),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFAF7C85), Color(0xFF975B73)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFFFEAEE),
                  child: Icon(Icons.person, size: 40, color: Color(0xFF451A2B)),
                ),
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
            leading: const Icon(Icons.home_rounded, color: Color(0xFFAF7C85)),
            title: const Text("Home",
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFFAF7C85),
                    fontWeight: FontWeight.w600)),
            tileColor: const Color(0xFFFFEAEE),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded,
                color: Color(0xFF451A2B)),
            title: const Text("Catalog",
                style:
                    TextStyle(fontFamily: 'Poppins', color: Color(0xFF451A2B))),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => GalleryScreen(
                          token: widget.token, user: widget.user)));
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.history_rounded, color: Color(0xFF451A2B)),
            title: const Text("History",
                style:
                    TextStyle(fontFamily: 'Poppins', color: Color(0xFF451A2B))),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => HistoryScreen(
                          token: widget.token, user: widget.user)));
            },
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
          ListTile(
            leading: Icon(isOnBreak ? Icons.coffee : Icons.work,
                color: isOnBreak ? Colors.orange : Colors.green),
            title: Text(isOnBreak ? "End Break" : "Start Break",
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: isOnBreak ? Colors.orange : Colors.green)),
            onTap: () {
              _toggleBreak();
              Navigator.pop(context);
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
                        color: Colors.black.withOpacity(0.05),
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
    return GestureDetector(
      onTap: () async {
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFAF7C85).withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Time Column
            Column(
              children: [
                Text(
                  reservation['reservation_time'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF451A2B),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEAEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Upcoming", // Or dynamic status
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: Color(0xFF975B73),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            // Divider
            Container(height: 50, width: 1, color: const Color(0xFFE5C1C8)),
            const SizedBox(width: 20),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reservation['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF451A2B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reservation['treatment_type'] ?? '-',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow Icon
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Color(0xFFE5C1C8)),
          ],
        ),
      ),
    );
  }
}

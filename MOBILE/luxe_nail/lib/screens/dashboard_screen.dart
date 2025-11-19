import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:luxe_nail/utils/responsive.dart';
import 'package:table_calendar/table_calendar.dart';

import 'gallery_screen.dart';
import 'jenis_treatment_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;

  DashboardScreen({super.key, required this.token, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> reservations = [];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchReservations();
  }

  // ========================= FETCH DATA =========================
  Future<void> fetchReservations() async {
    try {
      final url = Uri.parse(
        "https://unglorifying-rutha-insincerely.ngrok-free.dev/api/v1/reservations",
      );

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> all = json["data"];

        // FILTER: Hanya yang confirmed + sesuai tanggal
        String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

        final filtered = all.where((r) {
          return r["status"] == "confirmed" &&
              r["reservation_date"].toString().startsWith(dateStr);
        }).toList();

        setState(() {
          reservations = filtered;
        });
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("Fetch error: $e");
    }
  }

  // ========================= UI =========================
  @override
  Widget build(BuildContext context) {
    final sW = Responsive.sW(context, 1);
    final sH = Responsive.sH(context, 1);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFFFEAEE),

      drawer: Drawer(
        backgroundColor: const Color(0xFFFFF8F9),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFAF7C85)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30 * sW,
                    backgroundColor: const Color(0xFFFFEAEE),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFF451A2B),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Welcome, ${widget.user['name']}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF451A2B)),
              title: const Text(
                'Home',
                style: TextStyle(
                  color: Color(0xFF451A2B),
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF451A2B)),
              title: const Text(
                'Profile',
                style: TextStyle(
                  color: Color(0xFF451A2B),
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(token: widget.token),
                ),
              ),
            ),
            const Divider(color: Color(0xFFAF7C85)),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF451A2B)),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFF451A2B),
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              ),
            ),
          ],
        ),
      ),

      // ========================= BODY =========================
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(26, 60, 26, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => scaffoldKey.currentState!.openDrawer(),
                  child: const Icon(
                    Icons.menu,
                    size: 32,
                    color: Color(0xFF451A2B),
                  ),
                ),
                const Text(
                  'LUXE NAIL',
                  style: TextStyle(
                    color: Color(0xFF975B73),
                    fontSize: 20,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 26),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${widget.user['name']}!',
                      style: const TextStyle(
                        color: Color(0xFF451A2B),
                        fontSize: 32,
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 7),
                    const Text(
                      'Your customers are waiting 💅',
                      style: TextStyle(
                        color: Color(0xFF451A2B),
                        fontFamily: 'Poppins',
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),

                GestureDetector(
                  onTap: () => _showCalendarPopup(context),
                  child: const Icon(
                    Icons.calendar_month,
                    size: 32,
                    color: Color(0xFF451A2B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ========================= CONTENT =========================
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                image: const DecorationImage(
                  image: AssetImage("assets/images/Splas1-HAND.png"),
                  fit: BoxFit.cover,
                  opacity: 0.9,
                ),
              ),

              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Today's Appointments",
                      style: TextStyle(
                        color: Color(0xFF451A2B),
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (reservations.isEmpty)
                      const Text("No confirmed reservations today"),

                    if (reservations.isNotEmpty)
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: reservations
                            .map((r) => _appointmentCard(r))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
          ),

          _bottomNavbar(context),
        ],
      ),
    );
  }

  Widget _appointmentCard(dynamic r) {
    return GestureDetector(
      onTap: () {
        // nanti diarahkan ke design_screen.dart
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFAF7C85),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEAEE),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Reservation # ${r['queue_number']}",
                      style: const TextStyle(
                        color: Color(0xFF451A2B),
                        fontFamily: 'Poppins',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Divider(color: Color(0xFF451A2B)),
                  Text(
                    "Name: ${r['name']}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    "Address: ${r['address']}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    "Treatment: ${r['treatment_type']}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    "Phone: ${r['phone']}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    "Status: ${r['status']}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavbar(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: const BoxDecoration(color: Color(0xFFFFF8F9)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem("Home", Icons.home, () {}),
          _navItem("Design", Icons.brush, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => JenisTreatmentScreen(
                  token: widget.token,
                  user: widget.user,
                ),
              ),
            );
          }),
          _navItem("Gallery", Icons.photo_album, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    GalleryScreen(token: widget.token, user: widget.user),
              ),
            );
          }),
          _navItem("Profile", Icons.person, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(token: widget.token),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _navItem(String text, IconData icon, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: const Color(0xFF975B73)),
          const SizedBox(height: 3),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFCEA8BC),
              fontSize: 11,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ========================= CALENDAR =========================
  void _showCalendarPopup(BuildContext context) async {
    DateTime? picked = await showDialog(
      context: context,
      builder: (context) => CalendarDialog(selected: selectedDate),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
      fetchReservations();
    }
  }
}

class CalendarDialog extends StatefulWidget {
  final DateTime selected;
  const CalendarDialog({super.key, required this.selected});

  @override
  State<CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends State<CalendarDialog> {
  late DateTime selectedDay;

  @override
  void initState() {
    super.initState();
    selectedDay = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFFF8F9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Appointment Date",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xFF451A2B),
              ),
            ),
            const SizedBox(height: 10),

            TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2026, 12, 31),
              focusedDay: selectedDay,
              selectedDayPredicate: (d) => isSameDay(d, selectedDay),
              onDaySelected: (sel, focus) {
                setState(() => selectedDay = sel);
              },
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: const Color(0xFFAF7C85).withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFFAF7C85),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: const Text(
                    "Close",
                    style: TextStyle(color: Color(0xFF451A2B)),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text(
                    "Select",
                    style: TextStyle(color: Color(0xFFAF7C85)),
                  ),
                  onPressed: () => Navigator.pop(context, selectedDay),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

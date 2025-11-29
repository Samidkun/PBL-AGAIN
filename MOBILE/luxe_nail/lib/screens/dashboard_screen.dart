import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:luxe_nail/screens/gallery_screen.dart';
import 'package:luxe_nail/screens/login_screen.dart';
import 'package:luxe_nail/screens/profile_screen.dart';
import 'package:table_calendar/table_calendar.dart';

import 'ai_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;

  const DashboardScreen({super.key, required this.token, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Consolidate variable names and initial state
  DateTime selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<dynamic> reservations = [];

  @override
  void initState() {
    super.initState();
    fetchReservations();
  }

  // ================================================================
  // FETCH DATA by DATE
  // ================================================================
  Future<void> fetchReservations() async {
    final baseUrl = dotenv.env['BASE_URL'];
    // Gunakan selectedDate untuk filtering
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    final url = Uri.parse("$baseUrl/api/v1/reservations?date=$formattedDate");

    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${widget.token}",
          "ngrok-skip-browser-warning": "true",
        },
      );

      // (Logic cek HTML/JSON response dihilangkan untuk clean code, asumsikan server kirim JSON)

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        List<dynamic> data = json["data"] ?? [];

        // Sort ascending by time
        data.sort((a, b) {
          final t1 = a['reservation_time'] ?? "00:00";
          final t2 = b['reservation_time'] ?? "00:00";
          return t1.compareTo(t2);
        });

        setState(() => reservations = data);
      } else {
        print("❌ FAILED RESPONSE (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("❌ ERROR FETCH: $e");
    }
  }

  // ================================================================
  // WIDGET CARD RESERVATION
  // ================================================================

  Widget _reservationCard(
    BuildContext context,
    Map<String, dynamic> res,
    double sW,
    double sH,
  ) {
    final name = res['name'] ?? 'No Name';
    final treatment = res['treatment_type'] ?? 'N/A';
    final timeText = res['reservation_time'] ?? '-';

    DateTime? resDate;
    try {
      if (res['reservation_date'] != null) {
        resDate = DateTime.parse(res['reservation_date']);
      }
    } catch (_) {}

    final dateText = DateFormat('d MMMM yyyy').format(resDate ?? selectedDate);

    return Container(
      margin: EdgeInsets.only(bottom: 16 * sH),
      padding: EdgeInsets.all(16 * sW),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F9), // soft bg sesuai template kamu
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFFFE1E7), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Nama + Chip Treatment =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF451A2B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEAEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  treatment,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFAF7C85),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12 * sH),

          // ===== Tanggal =====
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                size: 18,
                color: Color(0xFF975B73),
              ),
              const SizedBox(width: 8),
              Text(
                dateText,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF451A2B),
                ),
              ),
            ],
          ),

          SizedBox(height: 6 * sH),

          // ===== Jam =====
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Color(0xFF975B73)),
              const SizedBox(width: 8),
              Text(
                timeText,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF451A2B),
                ),
              ),
            ],
          ),

          SizedBox(height: 14 * sH),

          // ===== Tombol Konfirmasi =====
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AIScreen(
                    token: widget.token,
                    user: widget.user,
                    reservation: res,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14 * sH),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFAF7C85), Color(0xFF975B73)],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "confirm",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // BUILD UI
  // ================================================================
  @override
  Widget build(BuildContext context) {
    final sW = MediaQuery.of(context).size.width / 414;
    final sH = MediaQuery.of(context).size.height / 896;

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
                    radius: 30,
                    backgroundColor: const Color(0xFFFFEAEE),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFF451A2B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Welcome, ${widget.user['username']}!",
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
                "Home",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF451A2B),
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF451A2B)),
              title: const Text(
                "Profile",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF451A2B),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(token: widget.token),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_album, color: Color(0xFF451A2B)),
              title: const Text(
                "Gallery",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF451A2B),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        GalleryScreen(token: widget.token, user: widget.user),
                  ),
                );
              },
            ),

            const Divider(color: Color(0xFFAF7C85)),

            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF451A2B)),
              title: const Text(
                "Logout",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF451A2B),
                ),
              ),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      // ================================================================
      // BODY
      // ================================================================
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),

          // HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
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
                    fontSize: 22,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // ===== HELLO + ICON KALENDER =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, ${widget.user['username']}!",
                      style: const TextStyle(
                        color: Color(0xFF451A2B),
                        fontSize: 28,
                        fontFamily: 'Georgia',
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Your customers are waiting 💅",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        color: Color(0xFF451A2B),
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

          // ================= BOX PUTIH (TITLE + LIST SCROLL) =================
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  // FIX 3: Gunakan BorderRadius normal atau ganti dengan angka
                  topLeft: const Radius.circular(30),
                  topRight: const Radius.circular(30),
                ),
                image: const DecorationImage(
                  image: AssetImage("assets/images/Splas1-HAND.png"),
                  fit: BoxFit.cover,
                  opacity: 0.9,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== TITLE DI DALAM BOX PUTIH (TIDAK SCROLL) =====
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      26,
                      20,
                      26,
                      0,
                    ), // FIX 3: Hapus sW/sH
                    child: Text(
                      "Appointments on ${DateFormat('d MMM yyyy').format(selectedDate)}", // FIX 5: Tambahkan tanggal filter
                      style: const TextStyle(
                        color: Color(0xFF451A2B),
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: 10 * sH),

                  // ===== AREA SCROLL (CARD-CARD) =====
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ), // FIX 3: Hapus sW/sH
                      child: reservations.isEmpty
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 50,
                                      color: Color(0xFFB97A8B),
                                    ),
                                    SizedBox(height: 14),
                                    Text(
                                      "No reservations for this date",
                                      style: TextStyle(
                                        color: Color(0xFF451A2B),
                                        fontSize: 16,
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Try selecting another day 💅",
                                      style: TextStyle(
                                        color: Color(0xFF451A2B),
                                        fontSize: 13,
                                        fontFamily: "Poppins",
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              children: reservations
                                  .map(
                                    (res) =>
                                        _reservationCard(context, res, sW, sH),
                                  )
                                  .toList(),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // FIX 3: Hanya gunakan bottomNavigationBar, hapus yang ada di body
      bottomNavigationBar: _bottomNavbar(context),
    );
  }

  // ================================================================
  // BOTTOM NAVBAR
  // ================================================================
  Widget _bottomNavbar(BuildContext context) {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(27),
          topRight: Radius.circular(27),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 9,
            offset: Offset(5, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(Icons.home, "Home", () {
            // Biarkan di home
          }),

          _navItem(Icons.auto_awesome, "AI", () {
            // FIX 4: Tambahkan user: widget.user ke AIScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AIScreen(
                  token: widget.token,
                  user: widget.user,
                  reservation: null,
                ),
              ),
            );
          }),

          _navItem(Icons.photo_album, "Gallery", () {
            // FIX 4: Tambahkan user: widget.user ke GalleryScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    GalleryScreen(token: widget.token, user: widget.user),
              ),
            );
          }),

          _navItem(Icons.person, "Profile", () {
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

  Widget _navItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, // <-- pake parameter icon, bukan Icons.home terus
            size: 30,
            color: const Color(0xFF975B73),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: Color(0xFFCEA8BC),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // CALENDAR POPUP
  // ================================================================
  void _showCalendarPopup(BuildContext context) {
    _selectedDay = selectedDate;
    _focusedDay = selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        // Perlu StateBuilder untuk update _selectedDay di dalam dialog
        return StatefulBuilder(
          builder: (context, setStateInternal) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color(0xFFFFF8F9),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Select Appointment Date",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Color(0xFF451A2B),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Calendar
                    TableCalendar(
                      firstDay: DateTime.utc(2024, 1, 1),
                      lastDay: DateTime.utc(2026, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (sel, focus) {
                        // FIX 6: Gunakan setState internal untuk update tampilan kalender
                        setStateInternal(() {
                          _selectedDay = sel;
                          _focusedDay = focus;
                        });
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

                    const SizedBox(height: 10),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Close",
                            style: TextStyle(color: Color(0xFF451A2B)),
                          ),
                        ),

                        if (_selectedDay != null)
                          TextButton(
                            onPressed: () {
                              // SET FILTER DATE
                              setState(() {
                                // FIX 6: Gunakan setState luar untuk update main screen
                                selectedDate = _selectedDay!;
                                _focusedDay = _selectedDay!;
                              });

                              Navigator.pop(context);
                              fetchReservations(); // reload data

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Selected: ${DateFormat('d MMM yyyy').format(_selectedDay!)}",
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Select",
                              style: TextStyle(color: Color(0xFFAF7C85)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

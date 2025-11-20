import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:luxe_nail/screens/design_screen.dart';
import 'package:luxe_nail/screens/gallery_screen.dart';
import 'package:luxe_nail/screens/login_screen.dart';
import 'package:luxe_nail/screens/profile_screen.dart';
import 'package:luxe_nail/utils/responsive.dart';
import 'package:table_calendar/table_calendar.dart';

class DashboardScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;

  const DashboardScreen({super.key, required this.token, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> reservations = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchReservationsForDate(_selectedDate);
  }

  // ====================== FETCH DATA BY DATE ==========================
  Future<void> _fetchReservationsForDate(DateTime date) async {
    try {
      final url = Uri.parse(
        "https://unglorifying-rutha-insincerely.ngrok-free.dev/api/v1/reservations",
      );

      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> raw = data["data"] ?? [];
        final String selectedDateStr = DateFormat(
          "yyyy-MM-dd",
        ).format(date.toUtc());
        final List<dynamic> filtered = raw.where((item) {
          // reservation_date di API: "2025-11-26T00:00:00.000000Z"
          final String rawDate = (item["reservation_date"] ?? "").toString();
          final String onlyDate = rawDate.length >= 10
              ? rawDate.substring(0, 10)
              : rawDate;

          final String status = (item["status"] ?? "")
              .toString()
              .trim()
              .toLowerCase();

          return onlyDate == selectedDateStr && status == "confirmed";
        }).toList();

        // SORT by reservation_time (HH:mm:ss)
        DateTime parseTime(dynamic value) {
          final str = (value ?? "").toString();
          try {
            return DateFormat("HH:mm:ss").parse(str);
          } catch (_) {
            return DateTime(2000, 1, 1, 23, 59, 59);
          }
        }

        filtered.sort((a, b) {
          final tA = parseTime(a["reservation_time"]);
          final tB = parseTime(b["reservation_time"]);
          return tA.compareTo(tB);
        });

        setState(() {
          reservations = filtered;
        });
      } else {
        debugPrint("❌ Failed: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ ERROR: $e");
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _fetchReservationsForDate(date);
  }

  // =========================== UI ================================
  @override
  Widget build(BuildContext context) {
    final sW = Responsive.sW(context, 1);
    final sH = Responsive.sH(context, 1);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFFFEAEE),

      // ================= DRAWER =================
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
                  SizedBox(height: 10 * sH),
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(token: widget.token),
                  ),
                );
              },
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

      // ================= BODY =================
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER LUXE NAIL =====
          Padding(
            padding: EdgeInsets.fromLTRB(26 * sW, 60 * sH, 26 * sW, 10 * sH),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => scaffoldKey.currentState!.openDrawer(),
                  child: Icon(
                    Icons.menu,
                    size: 32 * sW,
                    color: const Color(0xFF451A2B),
                  ),
                ),
                Text(
                  'LUXE NAIL',
                  style: TextStyle(
                    color: const Color(0xFF975B73),
                    fontSize: 20 * sW,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // ===== HELLO + ICON KALENDER =====
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 26 * sW),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${widget.user['name']}!',
                      style: TextStyle(
                        color: const Color(0xFF451A2B),
                        fontSize: 32 * sW,
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 7 * sH),
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
                  child: Icon(
                    Icons.calendar_month,
                    size: 32 * sW,
                    color: const Color(0xFF451A2B),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20 * sH),

          // ================= BOX PUTIH (TITLE + LIST SCROLL) =================
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30 * sW),
                  topRight: Radius.circular(30 * sW),
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
                    padding: EdgeInsets.fromLTRB(26 * sW, 20 * sH, 26 * sW, 0),
                    child: const Text(
                      "Today's Appointments",
                      style: TextStyle(
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
                      padding: EdgeInsets.symmetric(
                        vertical: 10 * sH,
                        horizontal: 20 * sW,
                      ),
                      child: reservations.isEmpty
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
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

          // ====== BOTTOM NAVBAR ======
          _bottomNavbar(context, sW, sH),
        ],
      ),
    );
  }

  // ================= CARD DESIGN =================
  Widget _reservationCard(
    BuildContext context,
    Map<String, dynamic> res,
    double sW,
    double sH,
  ) {
    final treatment = (res["treatment_type"] ?? "").toString();
    final treatmentLabel = _prettyTreatment(treatment);
    final time = (res["reservation_time"] ?? "").toString();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DesignScreen(
              token: widget.token,
              user: widget.user,
              reservation: res,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16 * sH),
        padding: EdgeInsets.all(6 * sW),
        decoration: BoxDecoration(
          color: const Color(0xFFB97A8B),
          borderRadius: BorderRadius.circular(18 * sW),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 6,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(14 * sW),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F3),
            borderRadius: BorderRadius.circular(14 * sW),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Reservation #${res['queue_number']}",
                  style: TextStyle(
                    color: const Color(0xFF451A2B),
                    fontFamily: "Poppins",
                    fontSize: 14 * sW,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              SizedBox(height: 6 * sH),
              const Divider(color: Color(0xFF451A2B), thickness: 1, height: 1),
              SizedBox(height: 8 * sH),

              // baris icon treatment + label + jam
              Row(
                children: [
                  Icon(
                    _treatmentIcon(treatment),
                    size: 18 * sW,
                    color: const Color(0xFF451A2B),
                  ),
                  SizedBox(width: 8 * sW),
                  Text(
                    treatmentLabel,
                    style: TextStyle(
                      color: const Color(0xFF451A2B),
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                      fontSize: 13 * sW,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    time,
                    style: TextStyle(
                      color: const Color(0xFF451A2B),
                      fontFamily: "Poppins",
                      fontSize: 12 * sW,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10 * sH),

              _info("Name", res["name"]),
              _info("Address", res["address"]),
              _info("Phone", res["phone"]),
              _info("Status", res["status"]),
            ],
          ),
        ),
      ),
    );
  }

  IconData _treatmentIcon(String t) {
    switch (t) {
      case "nail_art":
        return Icons.brush;
      case "nail_extension":
        return Icons.pan_tool_alt;
      default:
        return Icons.brush;
    }
  }

  String _prettyTreatment(String t) {
    switch (t) {
      case "nail_art":
        return "Nail Art";
      case "nail_extension":
        return "Nail Extension";
      default:
        return t;
    }
  }

  Widget _info(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        "$label : ${value ?? '-'}",
        style: const TextStyle(
          fontSize: 13,
          fontFamily: "Poppins",
          color: Color(0xFF451A2B),
        ),
      ),
    );
  }

  // ================= BOTTOM NAV =================
  Widget _bottomNavbar(BuildContext context, double sW, double sH) {
    return Container(
      height: 90 * sH,
      padding: EdgeInsets.symmetric(horizontal: 40 * sW),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(27 * sW),
          topRight: Radius.circular(27 * sW),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 9,
            offset: Offset(5, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _bottomNavItem(label: "Home", icon: Icons.home, onTap: () {}),

          _bottomNavItem(
            label: "Design",
            icon: Icons.brush,
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DesignScreen(token: widget.token, user: widget.user),
              ),
            ),
          ),

          _bottomNavItem(
            label: "Gallery",
            icon: Icons.photo_album,
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    GalleryScreen(token: widget.token, user: widget.user),
              ),
            ),
          ),

          _bottomNavItem(
            label: "Profile",
            icon: Icons.person,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(token: widget.token),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: const Color(0xFF975B73)),
          const SizedBox(height: 3),
          Text(
            label,
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

  // ================= CALENDAR POPUP =================
  void _showCalendarPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        DateTime tempSelectedDay = _selectedDate;
        DateTime focusedDay = _selectedDate;

        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color(0xFFFFF8F9),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                  minWidth: MediaQuery.of(context).size.width * 0.90,
                ),
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
                        focusedDay: focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(tempSelectedDay, day),
                        onDaySelected: (sel, focus) {
                          setStateDialog(() {
                            tempSelectedDay = sel;
                            focusedDay = focus;
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            child: const Text(
                              "Close",
                              style: TextStyle(color: Color(0xFF451A2B)),
                            ),
                            onPressed: () => Navigator.pop(dialogCtx),
                          ),
                          TextButton(
                            child: const Text(
                              "Select",
                              style: TextStyle(color: Color(0xFFAF7C85)),
                            ),
                            onPressed: () {
                              Navigator.pop(dialogCtx);
                              _onDateSelected(tempSelectedDay);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

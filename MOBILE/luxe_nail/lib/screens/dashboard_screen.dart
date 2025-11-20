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

// ⭐ IMPORT AI SCREEN
import 'ai_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String token;
  final Map<String, dynamic> user;

  const DashboardScreen({super.key, required this.token, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> reservations = [];

  @override
  void initState() {
    super.initState();
    fetchReservations();
  }

  // ================= FETCH DATA RESERVASI =================
  Future<void> fetchReservations() async {
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
        setState(() {
          reservations = data["data"] ?? [];
        });
      } else {
        print("❌ Failed: ${response.body}");
      }
    } catch (e) {
      print("❌ ERROR: $e");
    }
  }

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
        children: [
          // ================= HEADER =================
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

          // ================= MAIN CONTENT =================
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

              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 20 * sH,
                    horizontal: 20 * sW,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Appointments",
                        style: TextStyle(
                          color: const Color(0xFF451A2B),
                          fontSize: 20 * sW,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),

          // ================= BOTTOM NAVBAR (UPDATED) =================
          Positioned(
            left: 0,
            top: 800 * sH,
            child: Container(
              width: 412 * sW,
              height: 120 * sH,
              padding: EdgeInsets.only(
                top: 24 * sH,
                left: 46 * sW,
                right: 46 * sW,
                bottom: 30 * sH,
              ),
              decoration: ShapeDecoration(
                color: const Color(0xFFFFF8F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(27 * sW),
                    topRight: Radius.circular(27 * sW),
                  ),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 9,
                    offset: Offset(5, -4),
                    spreadRadius: -1,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _bottomNavItem(
                    label: "Home",
                    icon: Icons.home,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DashboardScreen(token: token, user: user),
                      ),
                    ),
                  ),

                  _bottomNavItem(
                    label: "Design",
                    icon: Icons.brush,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JenisTreatmentScreen(token: token, user: user),
                      ),
                    ),
                  ),

                  // ⭐ AI BUTTON
                  _bottomNavItem(
                    label: "AI",
                    icon: Icons.auto_awesome,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AIScreen(token: token, user: user),
                      ),
                    ),
                  ),

                  _bottomNavItem(
                    label: "Gallery",
                    icon: Icons.photo_album,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GalleryScreen(token: token, user: user),
                      ),
                    ),
                  ),

                  _bottomNavItem(
                    label: "Profile",
                    icon: Icons.person,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(token: token),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          _bottomNavbar(context, sW, sH),
        ],
      ),
    );
  }

  // ================= CARD VIEW =================
  Widget _reservationCard(
    BuildContext context,
    Map<String, dynamic> res,
    double sW,
    double sH,
  ) {
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
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 16 * sH),
        padding: EdgeInsets.all(16 * sW),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEAEE),
          borderRadius: BorderRadius.circular(16 * sW),
          border: Border.all(color: const Color(0xFFAF7C85), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 6,
              offset: Offset(3, 3),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Reservation #${res['queue_number']}",
                style: const TextStyle(
                  color: Color(0xFF451A2B),
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Divider(color: Color(0xFF451A2B)),

            _info("Name", res["name"]),
            _info("Address", res["address"]),
            _info("Treatment", res["treatment_type"]),
            _info("Phone", res["phone"]),
            _info("Status", res["status"]),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        "$label : $value",
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
    DateTime focusedDay = DateTime.now();
    DateTime? selectedDay;

    showDialog(
      context: context,
      builder: (context) {
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

            child: SingleChildScrollView(
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
                          isSameDay(selectedDay, day),
                      onDaySelected: (sel, focus) {
                        setState(() {
                          selectedDay = sel;
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
                          onPressed: () => Navigator.pop(context),
                        ),
                        if (selectedDay != null)
                          TextButton(
                            child: const Text(
                              "Select",
                              style: TextStyle(color: Color(0xFFAF7C85)),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Selected: ${DateFormat('d MMM yyyy').format(selectedDay!)}",
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

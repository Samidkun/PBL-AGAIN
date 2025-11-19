import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luxe_nail/screens/jenis_treatment_screen.dart';
import 'package:luxe_nail/utils/responsive.dart';
import 'package:table_calendar/table_calendar.dart';

import 'gallery_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String token;
  final Map<String, dynamic> user;

  DashboardScreen({super.key, required this.token, required this.user});

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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
                    'Welcome, ${user['name']}!',
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
                    builder: (_) => ProfileScreen(token: token),
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
                      'Hello, ${user['name']}!',
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
                image: DecorationImage(
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
                      SizedBox(height: 20 * sH),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _appointmentCard(sW, sH),
                          SizedBox(width: 12 * sW),
                          _appointmentCard(sW, sH),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ================= BOTTOM NAVBAR =================
          _bottomNavbar(context, sW, sH),
        ],
      ),
    );
  }

  // ==================================================
  // COMPONENTS
  // ==================================================
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
                builder: (_) => JenisTreatmentScreen(token: token, user: user),
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
              MaterialPageRoute(builder: (_) => ProfileScreen(token: token)),
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
          SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
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

  Widget _appointmentCard(double sW, double sH) {
    return Container(
      width: 160 * sW,
      padding: EdgeInsets.all(10 * sW),
      decoration: BoxDecoration(
        color: const Color(0xFFAF7C85),
        borderRadius: BorderRadius.circular(12 * sW),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8 * sW),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEAEE),
              borderRadius: BorderRadius.circular(5 * sW),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Reservation #001',
                    style: TextStyle(
                      color: Color(0xFF451A2B),
                      fontFamily: 'Poppins',
                      fontSize: 12,
                    ),
                  ),
                ),
                Divider(color: Color(0xFF451A2B)),
                Text('Name : Bella', style: TextStyle(fontSize: 12)),
                Text('Treatment : Nail Art', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          SizedBox(height: 10 * sH),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _actionButton("Canceled", sW),
              SizedBox(width: 10 * sW),
              _actionButton("Confirm", sW),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String text, double sW) {
    return Container(
      width: 65 * sW,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF451A2B),
        borderRadius: BorderRadius.circular(14 * sW),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontFamily: 'Poppins',
          ),
        ),
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
              maxHeight: MediaQuery.of(context).size.height * 0.75, // 🔥 Aman!
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
                        selectedDay = sel;
                        focusedDay = focus;
                      },
                      headerStyle: const HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Color(0xFFAF7C85).withOpacity(0.4),
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

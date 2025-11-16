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

  const DashboardScreen({
    super.key,
    required this.token,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
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
      body: Stack(
        children: [
          // HEADER
          Positioned(
            left: 26 * sW,
            top: 60 * sH,
            child: SizedBox(
              width: 351 * sW,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE BAR
                  Row(
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
                  SizedBox(height: 39 * sH),

                  // GREETING
                  Row(
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
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _showCalendarPopup(context),
                        child: Icon(
                          Icons.calendar_month,
                          color: const Color(0xFF451A2B),
                          size: 32 * sW,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // MAIN CONTENT
          Positioned(
            left: 13 * sW,
            top: 250 * sH,
            child: Container(
              width: 386 * sW,
              height: 620 * sH,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30 * sW),
                    topRight: Radius.circular(30 * sW),
                  ),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: -10 * sW,
                    top: -10 * sH,
                    child: Opacity(
                      opacity: 0.9,
                      child: Image.asset(
                        "assets/images/Splas1-HAND.png",
                        width: 386 * sW,
                        height: 620 * sH,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 18 * sH,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        "Today's Appointments",
                        style: TextStyle(
                          color: const Color(0xFF451A2B),
                          fontSize: 20 * sW,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 73 * sH,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _appointmentCard(sW, sH),
                        SizedBox(width: 12 * sW),
                        _appointmentCard(sW, sH),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BOTTOM NAVBAR
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

  // ==================================================
  // COMPONENTS
  // ==================================================
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
          Icon(icon, color: const Color(0xFF975B73), size: 32),
          const SizedBox(height: 5),
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

  Widget _appointmentCard(double sW, double sH) {
    return Container(
      width: 179 * sW,
      padding: EdgeInsets.symmetric(horizontal: 8 * sW, vertical: 11 * sH),
      decoration: ShapeDecoration(
        color: const Color(0xFFAF7C85),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12 * sW),
        ),
        shadows: const [
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
                  child: Text('Reservation #001',
                      style: TextStyle(
                          color: Color(0xFF451A2B),
                          fontFamily: 'Poppins',
                          fontSize: 12)),
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
              SizedBox(width: 13 * sW),
              _actionButton("Confirm", sW),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String text, double sW) {
    return Container(
      width: 70 * sW,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF451A2B),
        borderRadius: BorderRadius.circular(14 * sW),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w400,
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
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFFFFF8F9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Select Appointment Date",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Color(0xFF451A2B),
            ),
          ),
          content: TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2026, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: (sel, focus) {
              setState(() {
                selectedDay = sel;
                focusedDay = focus;
              });
            },
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
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Color(0xFF451A2B))),
            ),
            if (selectedDay != null)
              TextButton(
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
                child: const Text("Select", style: TextStyle(color: Color(0xFFAF7C85))),
              ),
          ],
        ),
      ),
    );
  }
}

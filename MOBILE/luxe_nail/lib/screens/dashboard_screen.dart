import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luxe_nail/screens/jenis_treatment_screen.dart';
import 'package:luxe_nail/utils/responsive.dart';
import 'package:table_calendar/table_calendar.dart';

import 'gallery_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // ==== Ganti scale ke util kamu (TANPA ubah struktur penggunaan) ====
    final sW = Responsive.sW(context, 1); // == width / 412
    final sH = Responsive.sH(context, 1); // == height / 917

    return Scaffold(
      key: _scaffoldKey,
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
                    child: Icon(
                      Icons.person,
                      size: 40 * sW,
                      color: const Color(0xFF451A2B),
                    ),
                  ),
                  SizedBox(height: 10 * sH),
                  const Text(
                    'Welcome Nailist!',
                    style: TextStyle(
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
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF451A2B)),
              title: const Text(
                'Settings',
                style: TextStyle(
                  color: Color(0xFF451A2B),
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
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
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
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
          // ================= HEADER =================
          Positioned(
            left: 26 * sW,
            top: 60 * sH,
            child: SizedBox(
              width: 351 * sW,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LUXE NAIL ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _scaffoldKey.currentState!.openDrawer();
                        },
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

                  // HELLO TEXTS
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Teks kiri
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello Nailist!',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: const Color(0xFF451A2B),
                                    fontSize: 36 * sW,
                                    fontFamily: 'Georgia',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 7 * sH),
                                Text(
                                  'Your Customers are waiting ',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: const Color(0xFF451A2B),
                                    fontSize: 15 * sW,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),

                            // Ikon kanan
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
                ],
              ),
            ),
          ),

          // ================= MAIN CONTAINER =================
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
                    left: 0,
                    right: 0,
                    top: 18 * sH,
                    child: Center(
                      child: Text(
                        'Today’s Appointments',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF451A2B),
                          fontSize: 20 * sW,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 73 * sH,
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _appointmentCard(sW, sH),
                          SizedBox(width: 12 * sW),
                          _appointmentCard(sW, sH),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= BOTTOM NAVBAR =================
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
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                  _bottomNavItem(
                    label: "Design",
                    icon: Icons.brush,
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JenisTreatmentScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                  _bottomNavItem(
                    label: "Gallery",
                    icon: Icons.photo_album,
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GalleryScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                  _bottomNavItem(
                    label: "Profile",
                    icon: Icons.person,
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BOTTOM NAV ITEM =================
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
          const Text(''),
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

  // ================= APPOINTMENT CARD =================
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 6 * sW, vertical: 7 * sH),
            decoration: ShapeDecoration(
              color: const Color(0xFFFFEAEE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5 * sW),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'kode reservasi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF451A2B),
                      fontSize: 12 * sW,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Divider(color: const Color(0xFF451A2B), height: 8),
                Text(
                  'Name : nama Reserfator',
                  style: TextStyle(
                    color: const Color(0xFF451A2B),
                    fontSize: 12 * sW,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Divider(color: const Color(0xFF451A2B), height: 8),
                Text(
                  'treatment : treatment Reserfator',
                  style: TextStyle(
                    color: const Color(0xFF451A2B),
                    fontSize: 12 * sW,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 11 * sH),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _actionButton("Canceled", sW, sH),
              SizedBox(width: 13 * sW),
              _actionButton("Confirm", sW, sH),
            ],
          ),
        ],
      ),
    );
  }

  // ================= ACTION BUTTON =================
  Widget _actionButton(String text, double sW, double sH) {
    return Container(
      width: 70 * sW,
      padding: EdgeInsets.symmetric(vertical: 6 * sH),
      decoration: ShapeDecoration(
        color: const Color(0xFF451A2B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14 * sW),
        ),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12 * sW,
            fontFamily: 'Poppins',
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
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
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
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.55,
                        ),
                        child: TableCalendar(
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
                          availableGestures: AvailableGestures.all,
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: const Color(0xFFAF7C85).withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: Color(0xFFAF7C85),
                              shape: BoxShape.circle,
                            ),
                            defaultTextStyle: const TextStyle(
                              color: Color(0xFF451A2B),
                              fontFamily: 'Poppins',
                            ),
                            weekendTextStyle: const TextStyle(
                              color: Color(0xFF975B73),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          headerStyle: const HeaderStyle(
                            titleCentered: true,
                            formatButtonVisible: false,
                            titleTextStyle: TextStyle(
                              color: Color(0xFF451A2B),
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            leftChevronIcon: Icon(
                              Icons.chevron_left,
                              color: Color(0xFF451A2B),
                            ),
                            rightChevronIcon: Icon(
                              Icons.chevron_right,
                              color: Color(0xFF451A2B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Close",
                    style: TextStyle(
                      color: Color(0xFF451A2B),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (selectedDay != null)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Selected date: ${DateFormat('d MMM yyyy').format(selectedDay!)}",
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "Select",
                      style: TextStyle(
                        color: Color(0xFFAF7C85),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  DateTime selectedDate = DateTime.now(); // current filter date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay; // calendar selected day

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

      if (!response.headers["content-type"].toString().contains("application/json")) {
        print("❌ SERVER RETURNED HTML");
        print(response.body.substring(0, 200));
        return;
      }

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
        print("❌ FAILED RESPONSE: ${response.body}");
      }
    } catch (e) {
      print("❌ ERROR FETCH: $e");
    }
  }

  // ================================================================
  // BUILD UI
  // ================================================================
  @override
  Widget build(BuildContext context) {
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
                    child: const Icon(Icons.person, size: 40, color: Color(0xFF451A2B)),
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
              title: const Text("Home",
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Color(0xFF451A2B))),
              onTap: () => Navigator.pop(context),
            ),

            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF451A2B)),
              title: const Text("Profile",
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Color(0xFF451A2B))),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen(token: widget.token)),
                );
              },
            ),

//             ListTile(
//   leading: const Icon(Icons.brush),
//   title: const Text("AI Result"),
//   onTap: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => const AIResultScreen(),
//       ),
//     );
//   },
// ),



            const Divider(color: Color(0xFFAF7C85)),

            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF451A2B)),
              title: const Text("Logout",
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Color(0xFF451A2B))),
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
                  child: const Icon(Icons.menu, size: 32, color: Color(0xFF451A2B)),
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

          // SUBHEADER
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
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 15, color: Color(0xFF451A2B)),
                    ),
                  ],
                ),

                GestureDetector(
                  onTap: () => _showCalendarPopup(context),
                  child: const Icon(Icons.calendar_month, size: 32, color: Color(0xFF451A2B)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // LIST CONTENT
   Expanded(
  child: reservations.isEmpty
      ? const Center(
          child: Text(
            "No confirmed appointments found.",
            style: TextStyle(color: Color(0xFF451A2B)),
          ),
        )
      : ListView.builder(
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            final r = reservations[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AIScreen(
                      token: widget.token,
                      user: widget.user,
                      reservation: r, // ⬅️ kirim data reservasi ke AI Screen
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Color(0xFF975B73), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Reservation + Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Reservation #${r['queue_number']}",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF451A2B),
                          ),
                        ),
                        Text(
                          r['reservation_time'] ?? '-',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF975B73),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Treatment type
                    Row(
                      children: [
                        const Icon(Icons.brush,
                            size: 18, color: Color(0xFF975B73)),
                        const SizedBox(width: 6),
                        Text(
                          r['treatment_type'] == "nail_extension"
                              ? "Nail Extension"
                              : "Nail Art",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Color(0xFF451A2B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Detail customer
                    Text(
                      "Name : ${r['name']}",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Color(0xFF451A2B),
                      ),
                    ),
                    Text(
                      "Address : ${r['address'] ?? '-'}",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Color(0xFF451A2B),
                      ),
                    ),
                    Text(
                      "Phone : ${r['phone']}",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Color(0xFF451A2B),
                      ),
                    ),
                    Text(
                      "Status : ${r['status']}",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Color(0xFF451A2B),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
)


        ],
      ),

      // BOTTOM NAV
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
          BoxShadow(color: Color(0x3F000000), blurRadius: 9, offset: Offset(5, -4)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(Icons.home, "Home", () {}),

          _navItem(Icons.auto_awesome, "AI", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AIScreen(token: widget.token, user: widget.user),
              ),
            );
          }),

          _navItem(Icons.photo_album, "Gallery", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GalleryScreen(token: widget.token, user: widget.user),
              ),
            );
          }),

          _navItem(Icons.person, "Profile", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileScreen(token: widget.token)),
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
          Icon(icon, size: 30, color: Color(0xFF975B73)),
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
  // Sync selected calendar date dengan tanggal filter aktif
  _selectedDay = selectedDate;
  _focusedDay = selectedDate;

  showDialog(
    context: context,
    builder: (context) {
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
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (sel, focus) {
                  setState(() {
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
}

}

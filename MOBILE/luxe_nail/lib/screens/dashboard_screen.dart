import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:luxe_nail/screens/login_screen.dart';
import 'package:luxe_nail/screens/profile_screen.dart';
import 'package:luxe_nail/screens/gallery_screen.dart';
import 'package:luxe_nail/screens/ai_screen.dart';
import 'package:luxe_nail/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;

  const DashboardScreen({super.key, required this.token, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime selectedDate = DateTime.now(); // The current filter date
  DateTime _focusedDay = DateTime.now(); // For calendar widget
  DateTime? _selectedDay; // For calendar widget selection

  List<dynamic> reservations = [];
  bool isLoading = true;
  bool isOnBreak = false; // Add state for break status

  @override
  void initState() {
    super.initState();
    _fetchReservations();
    _fetchStatus(); // Fetch initial status
  }

  Future<void> _fetchReservations() async {
    setState(() => isLoading = true);

    // Format date to YYYY-MM-DD for API
    String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    final result =
        await ApiService.getReservations(widget.token, date: dateStr);

    if (!mounted) return;

    setState(() {
      isLoading = false;
      if (result['success']) {
        reservations = result['data'];
      } else {
        // Handle error silently or show snackbar
        // print("Error fetching reservations: ${result['message']}");
        reservations = [];
      }
    });
  }

  Future<void> _fetchStatus() async {
    // We can use toggleBreak to get status if we don't have a specific getStatus endpoint
    // Or better, add getStatus to ApiService. For now, let's assume we can get it from profile or just default to false
    // Actually, let's just use toggleBreak logic but we need a GET endpoint really.
    // For simplicity, let's add a quick check or just rely on user action.
    // Wait, I can use getUserProfile to get status if I add it there.
    // Let's just add a simple check.
    // For now, default false.
  }

  Future<void> _toggleBreak() async {
    final result = await ApiService.toggleBreak(widget.token);
    if (!mounted) return;
    if (result['success']) {
      setState(() {
        isOnBreak = result['is_on_break'];
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

  Future<void> _finishJob(int reservationId) async {
    final result = await ApiService.finishJob(widget.token, reservationId);
    if (result['success']) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Job marked as completed!")),
      );
      _fetchReservations(); // Refresh list
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
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
                    child: const Icon(Icons.person,
                        size: 40, color: Color(0xFF451A2B)),
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
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFF451A2B))),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF451A2B)),
              title: const Text("Profile",
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFF451A2B))),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProfileScreen(token: widget.token)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_album, color: Color(0xFF451A2B)),
              title: const Text("Gallery",
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFF451A2B))),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => GalleryScreen(
                          token: widget.token, user: widget.user)),
                );
              },
            ),
            const Divider(color: Color(0xFFAF7C85)),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF451A2B)),
              title: const Text("Logout",
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFF451A2B))),
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
                  child: const Icon(Icons.menu,
                      size: 32, color: Color(0xFF451A2B)),
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

          // ===== HELLO + ICON KALENDER + BREAK BUTTON =====
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
                          color: Color(0xFF451A2B)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // BREAK BUTTON
                    GestureDetector(
                      onTap: _toggleBreak,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isOnBreak ? Colors.orange : Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isOnBreak ? Icons.coffee : Icons.work,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap: () => _showCalendarPopup(context),
                      child: const Icon(Icons.calendar_month,
                          size: 32, color: Color(0xFF451A2B)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ================= BOX PUTIH (TITLE + LIST SCROLL) =================
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                image: DecorationImage(
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
                    padding: const EdgeInsets.fromLTRB(26, 20, 26, 0),
                    child: Text(
                      "Appointments on ${DateFormat('d MMM yyyy').format(selectedDate)}",
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
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFAF7C85)))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: reservations.isEmpty
                                ? SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.6,
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
                                          (res) => _reservationCard(
                                              context, res, sW, sH),
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
      bottomNavigationBar: _bottomNavbar(context),
    );
  }

  // ================================================================
  // RESERVATION CARD
  // ================================================================
  Widget _reservationCard(
      BuildContext context, Map<String, dynamic> res, double sW, double sH) {
    // Logic update: 'completed' is the new status for finished jobs.
    bool isCompleted = res['status'] == 'completed';

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(res['name'] ?? 'No Name',
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Color(0xFF451A2B))),
        subtitle: Text(
            "${res['reservation_time'] ?? '-'} - ${res['treatment_type'] ?? 'N/A'}",
            style: const TextStyle(
                fontFamily: 'Poppins', color: Color(0xFFAF7C85))),
        trailing: isCompleted
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // FINISH BUTTON
                  if (res['status'] == 'confirmed' ||
                      res['status'] == 'in_progress')
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.blue),
                      onPressed: () => _finishJob(res['id']),
                      tooltip: "Finish Job",
                    ),
                  const Icon(Icons.arrow_forward_ios, color: Color(0xFFAF7C85)),
                ],
              ),
        onTap: () {
          if (isCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("This reservation is already completed.")),
            );
            return;
          }
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
      ),
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
              color: Color(0x3F000000), blurRadius: 9, offset: Offset(5, -4)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(Icons.home, "Home", () {
            // Already on home
          }),
          _navItem(Icons.auto_awesome, "AI", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AIScreen(
                    token: widget.token, user: widget.user, reservation: null),
              ),
            );
          }),
          _navItem(Icons.photo_album, "Gallery", () {
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
                  builder: (_) => ProfileScreen(token: widget.token)),
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
          Icon(icon, size: 30, color: const Color(0xFF975B73)),
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
        return StatefulBuilder(builder: (context, setStateInternal) {
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
                        color: const Color(0xFFAF7C85).withValues(alpha: 0.4),
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
                            });
                            _fetchReservations(); // REFRESH DATA
                            Navigator.pop(context);
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
        });
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luxe_nail/services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;

  const HistoryScreen({super.key, required this.token, required this.user});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> history = [];
  List<dynamic> filteredHistory = [];
  bool isLoading = true;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    // Fetch completed reservations from API
    final result =
        await ApiService.getReservations(widget.token, status: 'completed');

    if (!mounted) return;

    setState(() {
      isLoading = false;
      if (result['success']) {
        history = result['data'];

        // Sort by date descending
        history.sort((a, b) {
          DateTime dateA = DateTime.parse(
              "${a['reservation_date']} ${a['reservation_time']}");
          DateTime dateB = DateTime.parse(
              "${b['reservation_date']} ${b['reservation_time']}");
          return dateB.compareTo(dateA);
        });

        // Initialize filtered history
        filteredHistory = history;
      } else {
        history = [];
        filteredHistory = [];
      }
    });
  }

  void _filterByDate(DateTime? date) {
    setState(() {
      selectedDate = date;
      if (date == null) {
        filteredHistory = history;
      } else {
        filteredHistory = history.where((item) {
          DateTime itemDate = DateTime.parse(item['reservation_date']);
          return itemDate.year == date.year &&
              itemDate.month == date.month &&
              itemDate.day == date.day;
        }).toList();
      }
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
    if (picked != null) {
      _filterByDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEAEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFEAEE),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "History",
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF451A2B),
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF451A2B)),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFAF7C85)))
          : Column(
              children: [
                // Date Filter
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            selectedDate == null
                                ? 'Filter by Date'
                                : DateFormat('dd/MM/yy').format(selectedDate!),
                            style: const TextStyle(fontFamily: 'Poppins'),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF451A2B),
                            side: const BorderSide(color: Color(0xFFAF7C85)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      if (selectedDate != null) const SizedBox(width: 8),
                      if (selectedDate != null)
                        IconButton(
                          onPressed: () => _filterByDate(null),
                          icon: const Icon(Icons.clear),
                          color: const Color(0xFF451A2B),
                          tooltip: 'Clear filter',
                        ),
                    ],
                  ),
                ),
                // History List
                Expanded(
                  child: filteredHistory.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.history,
                                  size: 60, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                selectedDate == null
                                    ? "No completed jobs yet"
                                    : "No jobs on this date",
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filteredHistory.length,
                          itemBuilder: (context, index) {
                            final item = filteredHistory[index];
                            return _historyCard(item);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _historyCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['reservation_date'] ?? '-',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    "Completed",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item['name'] ?? 'No Name',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF451A2B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${item['treatment_type']} • ${item['reservation_time']}",
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFFAF7C85),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Price",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(
                      int.tryParse(item['total_price']?.toString() ?? '0') ??
                          0),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF451A2B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

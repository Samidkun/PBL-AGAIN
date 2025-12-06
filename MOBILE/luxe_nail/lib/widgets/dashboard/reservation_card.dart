import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReservationCard extends StatelessWidget {
  final Map<String, dynamic> reservation;
  final VoidCallback onTap;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Check if reservation is for today
    String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String resDate = reservation['reservation_date'] ?? '';
    bool isToday = resDate == todayStr;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isToday
              ? Colors.white
              : Colors.grey[100], // Grey out if not today
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFAF7C85).withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Time Column
            Column(
              children: [
                Text(
                  reservation['reservation_time'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF451A2B),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEAEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Upcoming",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: Color(0xFF975B73),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            // Divider
            Container(height: 50, width: 1, color: const Color(0xFFE5C1C8)),
            const SizedBox(width: 20),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reservation['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF451A2B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reservation['treatment_type'] ?? '-',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow Icon
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Color(0xFFE5C1C8)),
          ],
        ),
      ),
    );
  }
}




import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final List<Map<String, dynamic>> monthlyData;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;

  const CalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.monthlyData,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  /// 🔥 Fast lookup
  Map<String, dynamic>? _getAttendance(DateTime day) {
    for (final item in monthlyData) {
      final date = item["date"];

      if (date is DateTime && isSameDay(date, day)) {
        return item;
      }
    }
    return null;
  }

  Color _getColor(String status) {
    switch (status) {
      case 'Present':
        return const Color(0xFF009227).withOpacity(0.15);
      case 'Absent':
        return const Color(0xFFCF0027).withOpacity(0.15);
      case 'Late':
        return const Color(0xFFE7AC00).withOpacity(0.15);
      case 'Leave':
        return const Color(0xFF359CC1).withOpacity(0.15);
      case 'Weekend':
        return Colors.blue.shade100;
      case 'Not Scheduled':
        return Colors.grey.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
      ),

      focusedDay: focusedDay,
      firstDay: DateTime.utc(2020),
      lastDay: DateTime.utc(2030),

      selectedDayPredicate: (day) =>
          selectedDay != null && isSameDay(selectedDay, day),

      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,

      availableGestures: AvailableGestures.none,

      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, _) {
          final att = _getAttendance(day);
          final status = att?['status'] ?? "Not Scheduled";

          return Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _getColor(status),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "${day.day}",
                style: const TextStyle(fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }
}
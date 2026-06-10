


Map<String, dynamic>? getAttendanceForDate(
  List<Map<String, dynamic>> data,
  DateTime date,
) {
  try {
    return data.firstWhere((d) {
      final dDate = d['date'];

      if (dDate is! DateTime) return false;

      return dDate.day == date.day &&
          dDate.month == date.month &&
          dDate.year == date.year;
    });
  } catch (e) {
    return null;
  }
}
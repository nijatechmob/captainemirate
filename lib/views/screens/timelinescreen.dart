import 'package:flutter/material.dart';
import '../../../core/constant/app_color.dart';

class Timelinescreen extends StatefulWidget {
  const Timelinescreen({super.key});

  @override
  State<Timelinescreen> createState() => _TimelinescreenState();
}

class _TimelinescreenState extends State<Timelinescreen> {
  int? selectedDay;
  String? selectedMonth;
  int? selectedYear;

  final List<String> months = [
    "All",
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];

  final List<int> years = [2024, 2025, 2026, 2027];

  final List<Map<String, dynamic>> allData = [
    {
      "date": DateTime(2026, 4, 10),
      "so": "SO #01",
      "status": "Completed",
      "totalHours": "12 Hours",
      "checkInA": "8:00 AM",
      "checkOutA": "12:00 PM",
      "travel": "1 hr",
      "checkInB": "2:00 PM",
      "checkOutB": "6:00 PM",
      "ot": "0 hr",
    },
    {
      "date": DateTime(2026, 4, 9),
      "so": "SO #02",
      "status": "Pending",
      "totalHours": "10 Hours",
      "checkInA": "8:00 AM",
      "checkOutA": "12:00 PM",
      "travel": "1 hr",
      "checkInB": "2:00 PM",
      "checkOutB": "5:00 PM",
      "ot": "1 hr",
    },
    {
      "date": DateTime(2026, 4, 8),
      "so": "SO #03",
      "status": "Pending",
      "totalHours": "10 Hours",
      "checkInA": "8:00 AM",
      "checkOutA": "12:00 PM",
      "travel": "1 hr",
      "checkInB": "2:00 PM",
      "checkOutB": "5:00 PM",
      "ot": "1 hr",
    },
  ];

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    selectedDay = now.day;
    selectedMonth = months[now.month];
    selectedYear = now.year;
  }

  /// ✅ GET DAYS IN MONTH
  int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// ✅ DYNAMIC DAY LIST
  List<dynamic> get dayList {
    if (selectedMonth == null || selectedMonth == "All") {
      return ["All", ...List.generate(31, (i) => i + 1)];
    }

    int monthIndex = months.indexOf(selectedMonth!);
    int days = getDaysInMonth(selectedYear!, monthIndex);

    return ["All", ...List.generate(days, (i) => i + 1)];
  }

  /// 🔥 FILTER LOGIC
  List<Map<String, dynamic>> get filteredData {
    return allData.where((e) {
      final date = e["date"] as DateTime;

      bool dayMatch =
          selectedDay == null || date.day == selectedDay;

      bool monthMatch = selectedMonth == "All"
          ? true
          : date.month == months.indexOf(selectedMonth!);

      bool yearMatch = date.year == selectedYear;

      return dayMatch && monthMatch && yearMatch;
    }).toList();
  }

  /// 🔥 BOTTOM SHEET
  void showBottomPicker({
    required List items,
    required String title,
    required Function(dynamic) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(items[index].toString()),
                      onTap: () {
                        Navigator.pop(context);
                        onSelect(items[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildBox({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primarylight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 5),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget rowItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13, color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.bgPage,
        title: const Text("Timeline Reports"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// FILTER ROW
            Row(
              children: [

                /// DATE
                buildBox(
                  title: "Date",
                  value: selectedDay?.toString() ?? "All",
                  onTap: () {
                    showBottomPicker(
                      title: "Select Day",
                      items: dayList,
                      onSelect: (val) {
                        setState(() {
                          selectedDay = val == "All"
                              ? null
                              : int.parse(val.toString());
                        });
                      },
                    );
                  },
                ),

                /// MONTH
                buildBox(
                  title: "Month",
                  value: selectedMonth ?? "All",
                  onTap: () {
                    showBottomPicker(
                      title: "Select Month",
                      items: months,
                      onSelect: (val) {
                        setState(() {
                          selectedMonth = val;
                          selectedDay = null; // reset
                        });
                      },
                    );
                  },
                ),

                /// YEAR
                buildBox(
                  title: "Year",
                  value: selectedYear.toString(),
                  onTap: () {
                    showBottomPicker(
                      title: "Select Year",
                      items: years,
                      onSelect: (val) {
                        setState(() {
                          selectedYear = int.parse(val.toString());
                          selectedDay = null; // reset
                        });
                      },
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// LIST
            Expanded(
              child: filteredData.isEmpty
                  ? const Center(child: Text("No Data Found"))
                  : ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final item = filteredData[index];
                        final date = item["date"] as DateTime;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(14),
                                border: const Border(
      left: BorderSide(
        color:AppColors.primary,
        width: 4,
      ),
    ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                "${item["so"]} (${item["status"]})",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 8),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item["totalHours"],
                                    style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${date.day}/${date.month}/${date.year}",
                                    style: const TextStyle(
                                        color: Colors.grey),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              rowItem("CheckIn (A)", item["checkInA"]),
                              rowItem("CheckOut", item["checkOutA"]),
                              rowItem("Travel", item["travel"]),

                              const Divider(),

                              rowItem("CheckIn (B)", item["checkInB"]),
                              rowItem("CheckOut", item["checkOutB"]),
                              rowItem("OT Hours", item["ot"]),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
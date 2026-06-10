import 'package:flutter/material.dart';

import '../core/constant/app_color.dart';

class CustomDatePickerWidget extends StatelessWidget {
  final String labelText;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final double? height;
  final double? width;

  const CustomDatePickerWidget({
    super.key,
    required this.labelText,
    required this.onDateSelected,
    this.selectedDate,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 55.0,
      width: width ?? MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            onDateSelected(pickedDate);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: labelText,
            filled: true,
            fillColor: Colors.transparent,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            floatingLabelStyle: const TextStyle(
              fontSize: 16,
              color: AppColors.primary,
            ),
            labelStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.darker,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: AppColors.grey, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedDate != null
                    ? "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}"
                    : "Select Date",
                style: const TextStyle(fontSize: 16),
              ),
              const Icon(Icons.calendar_today, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

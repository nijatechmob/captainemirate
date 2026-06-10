import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/constant/app_color.dart';

class AppUtils {
  // =========================
  // Keyboard
  // =========================
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  // =========================
  // String helpers
  // =========================
  static String capitalize(String value) =>
      value.trim().isNotEmpty ? value.toUpperCase() : value;

  // =========================
  // SNACKBAR (SAFE + SINGLE)
  // =========================
  static void showSnackbar({
    required BuildContext context,
    required String message,
    Color backgroundColor = Colors.black,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(message),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // backward compatibility (optional)
  static void errorsnackBar(String message, BuildContext context) {
    showSnackbar(
      context: context,
      message: message,
      backgroundColor: Colors.red,
    );
  }

  static void successsnackBar(String message, BuildContext context) {
    showSnackbar(
      context: context,
      message: message,
      backgroundColor: Colors.green,
    );
  }

  // =========================
  // Single button dialog
  // =========================
  static Future showSingleDialogPopup(
    BuildContext context,
    String title,
    String buttonName,
    VoidCallback onPressed,
    String? iconPath,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          icon: iconPath != null
              ? Image.asset(iconPath, width: 80, height: 80)
              : null,
          title: Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: onPressed,
              child: Text(buttonName),
            )
          ],
        );
      },
    );
  }

  // =========================
  // Confirmation dialog
  // =========================
  static Future showconfirmDialog(
    BuildContext context,
    String title,
    String yesText,
    String noText,
    VoidCallback onPressedYes,
    VoidCallback onPressedNo,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontSize: 16)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(0, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onPressedYes,
              child: Text(yesText),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onPressedNo,
              child: Text(noText),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // Text widgets
  // =========================
  static Widget buildHeaderText(String s, {required String text}) {
    return Text(
      text,
      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
    );
  }

  static Widget buildNormalText({
    required String text,
    Color color = Colors.black,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w400,
    TextAlign textAlign = TextAlign.left,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }

  static Widget iconWithText({
    required IconData icon,
    required String text,
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
    double fontSize = 12,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor,
          ),
        ),
      ],
    );
  }

  // =========================
  // Cupertino bottom sheet
  // =========================
  static void showBottomCupertinoDialog(
    BuildContext context, {
    required String title,
    required VoidCallback cameraAction,
    required VoidCallback fileAction,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text(title),
        actions: [
          CupertinoActionSheetAction(
            onPressed: cameraAction,
            child: const Text('Camera'),
          ),
          CupertinoActionSheetAction(
            onPressed: fileAction,
            child: const Text('Files'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  // =========================
  // Navigation helpers
  // =========================
  static void pop(BuildContext context) {
    Navigator.pop(context);
  }

  static Widget bottomHanger(BuildContext context) {
    return Center(
      child: Container(
        height: 5,
        width: MediaQuery.of(context).size.width / 6,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }

  static void changeNodeFocus(
    BuildContext context, {
    required FocusNode current,
    required FocusNode next,
  }) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  // =========================
  // Utils
  // =========================
  static double averageRatings(List<int> ratings) {
    if (ratings.isEmpty) return 0;
    double sum = ratings.reduce((a, b) => a + b).toDouble();
    return sum / ratings.length;
  }
}

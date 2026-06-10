import 'package:flutter/material.dart';

/// FM Asset Tracker — Centralized Color Configuration
/// All colors used across the app are defined here.
/// To change any color app-wide, edit only this file.

class AppColors {
  AppColors._();

  // ─── Brand Colors ──────────────────────────────────────────────
  static const Color primary = Color(
    0xFF359CC1,
  ); // Navy — AppBar, headers, buttons
  static const Color primaryDark = Color(0xFF243655); // Darker navy — gradients
  static const Color accent = Color(
    0xFFF47C20,
  ); // Orange — FAB, highlights, CTAs
  static const Color primarylight = Color(0xFFEDEEFF);

  // ─── Calender Colors ─────────────────────────────────────────────

  static const Color blue = Color(0xFF3085FE);
  static const Color bluelit = Color(0xFF359CC1);
  static const Color teal = Color(0xFF30BEB6);

  static const Color green = Color(0xFF009227);
  static const Color red = Color(0xFFCF0027);

  static const Color yellow = Color(0xFFE7AC00);

  // ─── Status Colors ─────────────────────────────────────────────
  static const Color statusActive = Color(0xFF16A34A); // Green
  static const Color statusMaintenance = Color(0xFFF59E0B); // Amber
  static const Color statusIdle = Color(0xFF6B7280); // Gray
  static const Color statusInTransit = Color(0xFF2563EB); // Blue
  static const Color statusDisposed = Color(0xFF7F1D1D); // Dark red

  // ─── Warranty Colors ───────────────────────────────────────────
  static const Color warrantyValid = Color(0xFF16A34A); // Green
  static const Color warrantyExpiringSoon = Color(0xFFF47C20); // Orange
  static const Color warrantyExpired = Color(0xFFEB5757); // Red

  // ─── Semantic Colors ───────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEB5757);
  static const Color info = Color(0xFF2563EB);

  // ─── Text Colors ───────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A2B4A); // Dark navy
  static const Color textSecondary = Color(0xFF374151); // Dark gray
  static const Color textMuted = Color(0xFF6B7280); // Medium gray
  static const Color textHint = Color(0xFF9CA3AF); // Light gray
  static const Color textDark = Color(0xFF1F2937); // Nearly black

  // ─── Background Colors ─────────────────────────────────────────
  static const Color bgPage = Color(0xFFF5F7FA); // Page background
  static const Color bgCard = Color(0xFFFFFFFF); // Card background
  static const Color bgCamera = Color(0xFF0A0A0A); // Scanner camera bg
  static const Color bgCameraIcon = Color(0xFF333333); // Scanner icon

  // ─── Border / Divider Colors ───────────────────────────────────
  static const Color border = Color(0xFFE5E7EB); // Default border
  static const Color borderLight = Color(
    0xFFE0E0E0,
  ); // Light border (input fields)

  // ─── Tint / Surface Colors ─────────────────────────────────────
  static const Color successSurface = Color(0xFFF0FDF4); // Light green bg
  static const Color warningSurface = Color(0xFFFFF7ED); // Light orange bg
  static const Color warningText = Color(0xFF92400E); // Orange dark text
  static const Color successText = Color(0xFF166534); // Green dark text

  // ─── Priority Colors ───────────────────────────────────────────
  static const Color priorityLow = Color(0xFF2563EB); // Blue
  static const Color priorityMedium = Color(0xFFF59E0B); // Amber
  static const Color priorityHigh = Color(0xFFEB5757); // Red
  static const Color priorityCritical = Color(0xFF7F1D1D); // Dark red

  // ─── Helpers ───────────────────────────────────────────────────

  /// Returns the color for a given asset status string
  static Color statusColor(String status) {
    switch (status) {
      case 'Active':
        return statusActive;
      case 'Maintenance':
        return statusMaintenance;
      case 'Idle':
        return statusIdle;
      case 'In Transit':
        return statusInTransit;
      case 'Under Maintenance':
        return statusMaintenance;
      case 'Disposed':
        return statusDisposed;
      default:
        return textMuted;
    }
  }

  /// Returns the color for a given warranty status string
  static Color warrantyColor(String warranty) {
    switch (warranty) {
      case 'In Warranty':
        return warrantyValid;
      case 'Expiring Soon':
        return warrantyExpiringSoon;
      case 'Expired':
        return warrantyExpired;
      default:
        return textMuted;
    }
  }

  /// Returns the color for a given priority string
  static Color priorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return priorityLow;
      case 'Medium':
        return priorityMedium;
      case 'High':
        return priorityHigh;
      case 'Critical':
        return priorityCritical;
      default:
        return textMuted;
    }
  }

  static const grey = Color(0xFF8F8F8F);

  static const secondary = Color(0xFFe96561);
  static const litgrey = Color(0xFFACB5BB);
  static const darker = Color(0xFF3E4249);
  static const light = Colors.white;
}

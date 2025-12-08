import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4A6CF7);
  static const Color background = Color(0xFFF7F8FA);
  static const Color cardBackground = Colors.white;
  static const Color expense = Color(0xFFEF4444);
  static const Color income = Color(0xFF22C55E);
  static const Color neutral = Color(0xFFE5E7EB);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  
  // Category colors
  static const Map<String, Color> categoryColors = {
    'Food': Color(0xFFF59E0B),
    'Shopping': Color(0xFF8B5CF6),
    'Transport': Color(0xFF3B82F6),
    'Entertainment': Color(0xFFEC4899),
    'Bills': Color(0xFF10B981),
    'Healthcare': Color(0xFFEF4444),
    'Education': Color(0xFF6366F1),
    'Other': Color(0xFF6B7280),
    'Income': Color(0xFF22C55E),
  };

  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? primary;
  }
}
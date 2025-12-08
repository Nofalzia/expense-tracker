import 'package:flutter/material.dart';  // ADD THIS IMPORT
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String? id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final bool isExpense;
  final String? note;
  final String? userId;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.isExpense,
    this.note,
    this.userId,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': date,
      'category': category,
      'isExpense': isExpense,
      'note': note ?? '',
      if (userId != null) 'userId': userId,
    };
  }

  // Create from Map (from Firestore)
  factory TransactionModel.fromMap(String id, Map<String, dynamic> map) {
    return TransactionModel(
      id: id,
      title: map['title'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      category: map['category'] ?? '',
      isExpense: map['isExpense'] ?? true,
      note: map['note'],
      userId: map['userId'],
    );
  }

  // Copy with method for updates
  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    bool? isExpense,
    String? note,
    String? userId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      isExpense: isExpense ?? this.isExpense,
      note: note ?? this.note,
      userId: userId ?? this.userId,
    );
  }

  // Helper methods
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  String get formattedAmount {
    return '${isExpense ? '-' : '+'}\$${amount.toStringAsFixed(2)}';
  }

  // FIXED: Remove 'const' from Color constructor
  Color get amountColor {
    return isExpense ? Color(0xFFEF4444) : Color(0xFF22C55E);
  }
}
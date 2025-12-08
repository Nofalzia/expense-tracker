import 'package:flutter/material.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final bool isExpense;
  String? note; // Add this line

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.isExpense,
    this.note, // Add this
  });
}

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // Sample data for testing
  TransactionProvider() {
    // Add some sample transactions
    _transactions = [
      Transaction(
        id: '1',
        title: 'Groceries',
        amount: 45.99,
        date: DateTime.now().subtract(Duration(days: 1)),
        category: 'Food',
        isExpense: true,
      ),
      Transaction(
        id: '2',
        title: 'Salary',
        amount: 2500.00,
        date: DateTime.now().subtract(Duration(days: 2)),
        category: 'Income',
        isExpense: false,
      ),
      Transaction(
        id: '3',
        title: 'Movie Tickets',
        amount: 25.50,
        date: DateTime.now().subtract(Duration(days: 3)),
        category: 'Entertainment',
        isExpense: true,
      ),
    ];
  }

  void addTransaction(Transaction transaction) {
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  void updateTransaction(String id, Transaction updatedTransaction) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      _transactions[index] = updatedTransaction;
      notifyListeners();
    }
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  double get totalIncome {
    return _transactions
        .where((t) => !t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpenses {
    return _transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get balance {
    return totalIncome - totalExpenses;
  }
}
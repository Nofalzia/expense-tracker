import 'package:flutter/material.dart';
import 'package:expense_tracker/services/firestore_service.dart';
import 'package:expense_tracker/models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  DateTime _selectedMonth = DateTime.now();
  bool _initialized = false;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  DateTime get selectedMonth => _selectedMonth;
  bool get isInitialized => _initialized;

  // Listen to transactions stream
  void startListening() {
    print('🎯 Starting to listen to Firestore stream...');
    
    _firestoreService.getTransactionsStream().listen(
      (transactions) {
        print('✅ Received ${transactions.length} transactions from stream');
        _transactions = transactions;
        notifyListeners();
      },
      onError: (error) {
        print('❌ Stream error: $error');
      },
      onDone: () {
        print('🏁 Stream closed');
      },
      cancelOnError: false,
    );
  }

  // Set selected month
  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
    _loadTransactionsForMonth();
  }

  // Load transactions for selected month
  Future<void> _loadTransactionsForMonth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final stream = _firestoreService.getTransactionsForMonth(_selectedMonth);
      stream.listen((transactions) {
        _transactions = transactions;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Add transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.addTransaction(transaction);
      print('✅ Transaction added to Firestore');
    } catch (e) {
      print('❌ Error adding transaction: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update transaction
  Future<void> updateTransaction(String id, TransactionModel transaction) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.updateTransaction(id, transaction);
      print('✅ Transaction updated in Firestore');
    } catch (e) {
      print('❌ Error updating transaction: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.deleteTransaction(id);
      print('✅ Transaction deleted from Firestore');
    } catch (e) {
      print('❌ Error deleting transaction: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate totals
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

  // Get recent transactions (last 5)
  List<TransactionModel> get recentTransactions {
    return _transactions.take(5).toList();
  }

  // Get transactions by category
  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    
    for (final transaction in _transactions.where((t) => t.isExpense)) {
      totals[transaction.category] = 
          (totals[transaction.category] ?? 0) + transaction.amount;
    }
    
    return totals;
  }

  // Initialize
  void initialize() {
    if (!_initialized) {
      print('🔧 Initializing TransactionProvider...');
      startListening();
      _initialized = true;
    }
  }
}
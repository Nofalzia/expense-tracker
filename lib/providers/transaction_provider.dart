import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:expense_tracker/services/firestore_service.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  DateTime _selectedMonth = DateTime.now();
  bool _initialized = false;
  StreamSubscription<List<TransactionModel>>? _transactionSubscription;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  DateTime get selectedMonth => _selectedMonth;
  bool get isInitialized => _initialized;

  // Get current user ID
  String? get _currentUserId {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  // Listen to transactions stream for selected month
  void startListening() {
    print('🎯 Starting to listen to Firestore stream...');
    
    final userId = _currentUserId;
    if (userId == null) {
      print('❌ No user logged in');
      return;
    }
    
    // Cancel existing subscription if any
    _transactionSubscription?.cancel();
    
    _isLoading = true;
    notifyListeners();

    print('📅 Listening for month: ${_selectedMonth.month}/${_selectedMonth.year}');
    
    _transactionSubscription = _firestoreService
        .getTransactionsForMonth(userId, _selectedMonth)
        .listen(
      (transactions) {
        print('✅ Received ${transactions.length} transactions from stream');
        _transactions = transactions;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('❌ Stream error: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Set selected month
  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    print('📅 Month changed to ${_selectedMonth.month}/${_selectedMonth.year}');
    notifyListeners();
    startListening(); // Restart listening with new month filter
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

  // Calculate totals for current month
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

  // Get recent transactions (last 5) sorted by date
  List<TransactionModel> get recentTransactions {
    // Since transactions are already ordered by date descending from Firestore
    // We can just take the first 5
    return _transactions.take(5).toList();
  }

  // Get transactions by category for current month
  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    
    for (final transaction in _transactions.where((t) => t.isExpense)) {
      totals[transaction.category] = 
          (totals[transaction.category] ?? 0) + transaction.amount;
    }
    
    return totals;
  }

  // Get transactions for a specific category
  List<TransactionModel> getTransactionsByCategory(String category) {
    return _transactions.where((t) => 
      t.category == category && 
      t.isExpense
    ).toList();
  }

  // Get all transactions (unfiltered) - for export or analytics
  Future<List<TransactionModel>> getAllTransactions() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    // This would need a new method in FirestoreService
    // For now, we'll just return current month's transactions
    return _transactions;
  }

  // Initialize
  void initialize() {
    if (!_initialized) {
      print('🔧 Initializing TransactionProvider...');
      startListening();
      _initialized = true;
    }
  }

  // Force refresh
  void refresh() {
    startListening();
  }

  // Clean up resources
  @override
  void dispose() {
    _transactionSubscription?.cancel();
    super.dispose();
  }
}
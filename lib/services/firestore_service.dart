import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/models/transaction.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _transactionsCollection => _firestore.collection('transactions');

  // ==================== USER OPERATIONS ====================

  Stream<List<TransactionModel>> getTransactionsStream(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    return _transactionsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get transactions for a specific month
  Stream<List<TransactionModel>> getTransactionsForMonth(String userId, DateTime month) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    return _transactionsCollection
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThanOrEqualTo: endOfMonth)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // ==================== CRUD OPERATIONS ====================

  // Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _transactionsCollection.add({
      ...transaction.toMap(),
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update a transaction
  Future<void> updateTransaction(String id, TransactionModel transaction) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _transactionsCollection.doc(id).update({
      ...transaction.toMap(),
      'userId': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete a transaction
  Future<void> deleteTransaction(String id) async {
    await _transactionsCollection.doc(id).delete();
  }

  // ==================== ANALYTICS ====================

  // Get total income for a month
  Future<double> getTotalIncomeForMonth(String userId, DateTime month) async {
    if (userId.isEmpty) return 0.0;

    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final query = await _transactionsCollection
        .where('userId', isEqualTo: userId)
        .where('isExpense', isEqualTo: false)
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThanOrEqualTo: endOfMonth)
        .get();

    double total = 0.0;
    for (final doc in query.docs) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data['amount'] as num).toDouble();
    }
    return total;
  }

  // Get total expenses for a month
  Future<double> getTotalExpensesForMonth(String userId, DateTime month) async {
    if (userId.isEmpty) return 0.0;

    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final query = await _transactionsCollection
        .where('userId', isEqualTo: userId)
        .where('isExpense', isEqualTo: true)
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThanOrEqualTo: endOfMonth)
        .get();

    double total = 0.0;
    for (final doc in query.docs) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data['amount'] as num).toDouble();
    }
    return total;
  }

  // Get transactions by category
  Future<Map<String, double>> getCategoryTotals(String userId, DateTime month) async {
    if (userId.isEmpty) return {};

    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final query = await _transactionsCollection
        .where('userId', isEqualTo: userId)
        .where('isExpense', isEqualTo: true)
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThanOrEqualTo: endOfMonth)
        .get();

    final Map<String, double> categoryTotals = {};

    for (final doc in query.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final category = data['category'] as String;
      final amount = (data['amount'] as num).toDouble();

      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }

    return categoryTotals;
  }
}
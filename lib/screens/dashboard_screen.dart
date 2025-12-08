import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/utils/colors.dart';
import 'package:expense_tracker/models/transaction.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isInitialized = false;
  int _selectedPeriod = 0; // 0: Month, 1: Week, 2: Year

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
        transactionProvider.initialize();
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Clean App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: Colors.white,
            titleSpacing: 20,
            toolbarHeight: 90,
            title: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    authProvider.userName ?? 'Welcome back',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 8),
                child: IconButton(
                  icon: Icon(Icons.analytics_outlined, color: Colors.black87, size: 24),
                  onPressed: () => Navigator.pushNamed(context, '/analytics'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: IconButton(
                  icon: Icon(Icons.logout, color: Colors.black87, size: 24),
                  onPressed: () {
                    authProvider.logout();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceCard(transactionProvider),
                  SizedBox(height: 28),
                  _buildPeriodSelector(),
                  SizedBox(height: 28),
                  _buildStatsCards(transactionProvider),
                  SizedBox(height: 32),

                  // Recent Transactions Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/transactions'),
                        child: Row(
                          children: [
                            Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18),

                  // If empty show empty state
                  if (transactionProvider.transactions.isEmpty)
                    _buildEmptyState()
                  else
                    _buildTransactionList(transactionProvider),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),

      // FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.add, color: Colors.white, size: 24),
        onPressed: () => Navigator.pushNamed(context, '/add-transaction'),
      ),
    );
  }

  // ============================
  // BALANCE CARD
  // ============================
  Widget _buildBalanceCard(TransactionProvider provider) {
    final balance = provider.balance;
    final isPositive = balance >= 0;

    return Container(
      padding: EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: isPositive ? AppColors.income.withOpacity(0.07) : AppColors.expense.withOpacity(0.07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPositive ? AppColors.income.withOpacity(0.18) : AppColors.expense.withOpacity(0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${balance.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w800,
                  color: isPositive ? AppColors.income : AppColors.expense,
                  letterSpacing: -0.7,
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.income : AppColors.expense).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? AppColors.income : AppColors.expense,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Text(
            isPositive ? 'Your finances look good' : 'Review your spending',
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================
  // PERIOD SELECTOR
  // ============================
  Widget _buildPeriodSelector() {
    final periods = ['This Month', 'This Week', 'This Year'];

    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: periods.asMap().entries.map((entry) {
          final index = entry.key;
          final period = entry.value;
          final isSelected = _selectedPeriod == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = index),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    period,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================
  // STATS CARDS
  // ============================
  Widget _buildStatsCards(TransactionProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            title: 'Income',
            amount: provider.totalIncome,
            color: AppColors.income,
            icon: Icons.arrow_downward,
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: _buildStatItem(
            title: 'Expenses',
            amount: provider.totalExpenses,
            color: AppColors.expense,
            icon: Icons.arrow_upward,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                '\$${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================
  // TRANSACTION LIST
  // ============================
  Widget _buildTransactionList(TransactionProvider provider) {
    final recentTransactions = provider.recentTransactions;

    return Column(
      children: recentTransactions.map((transaction) {
        return _buildTransactionItem(transaction);
      }).toList(),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final color = transaction.isExpense ? AppColors.expense : AppColors.income;

    return Dismissible(
      key: Key(transaction.id ?? '${transaction.title}-${transaction.date}'),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.expense.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete_outline, color: AppColors.expense),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Delete Transaction', style: TextStyle(fontWeight: FontWeight.w600)),
            content: Text('Delete "${transaction.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete', style: TextStyle(color: AppColors.expense)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        Provider.of<TransactionProvider>(context, listen: false)
            .deleteTransaction(transaction.id!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction deleted'),
            backgroundColor: AppColors.expense,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/add-transaction', arguments: transaction),
        child: Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.getCategoryColor(transaction.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  transaction.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                  color: AppColors.getCategoryColor(transaction.category),
                ),
              ),
              SizedBox(width: 16),

              // Title + Category/date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '${transaction.category} • ${transaction.formattedDate}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${transaction.isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      transaction.isExpense ? 'Expense' : 'Income',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================
  // EMPTY STATE
  // ============================
  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 62, color: Colors.grey.shade400),
          SizedBox(height: 14),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Add your first transaction to get started',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
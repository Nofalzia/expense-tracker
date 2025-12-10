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
  final List<String> _periods = ['Month', 'Week', 'Year'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final transactionProvider =
            Provider.of<TransactionProvider>(context, listen: false);
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
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      body: CustomScrollView(
        slivers: [
          // Clean Modern App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            titleSpacing: 20,
            expandedHeight: 10,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey.shade50,
                      Colors.grey.shade50.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    authProvider.userName ?? 'Welcome back',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20, top: 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Card - Minimal Design
                  _buildBalanceCard(transactionProvider),
                  const SizedBox(height: 32),

                  // Period Selector - Modern Segmented Control
                  _buildPeriodSelector(),
                  const SizedBox(height: 24),

                  // Stats Cards - Clean Layout
                  _buildStatsCards(transactionProvider),
                  const SizedBox(height: 32),

                  // Recent Transactions Header
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/transactions'),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Text(
                                  'View All',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded,
                                    size: 12, color: AppColors.primary),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Transaction List or Empty State
                  if (transactionProvider.transactions.isEmpty)
                    _buildEmptyState()
                  else
                    _buildTransactionList(transactionProvider),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      // Modern FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        onPressed: () => Navigator.pushNamed(context, '/add-transaction'),
      ),
    );
  }

  // ============================
  // BALANCE CARD - Minimal Design
  // ============================
  Widget _buildBalanceCard(TransactionProvider provider) {
    final balance = provider.balance;
    final isPositive = balance >= 0;
    final color = isPositive ? AppColors.income : AppColors.expense;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '\$${balance.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: color,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Income',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${provider.totalIncome.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.income,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.grey.shade200,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expenses',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${provider.totalExpenses.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.expense,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================
  // PERIOD SELECTOR - Modern Segmented Control
  // ============================
  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _periods.asMap().entries.map((entry) {
          final index = entry.key;
          final period = entry.value;
          final isSelected = _selectedPeriod == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
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
                      letterSpacing: 0.2,
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
  // STATS CARDS - Clean Modern Design
  // ============================
  Widget _buildStatsCards(TransactionProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            title: 'Income',
            amount: provider.totalIncome,
            color: AppColors.income,
            icon: Icons.arrow_downward_rounded,
            period: _periods[_selectedPeriod],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            title: 'Expenses',
            amount: provider.totalExpenses,
            color: AppColors.expense,
            icon: Icons.arrow_upward_rounded,
            period: _periods[_selectedPeriod],
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
    required String period,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.2), width: 1.5),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const Spacer(),
              Text(
                '\$${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'This $period',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================
  // TRANSACTION LIST - Clean & Flat Design
  // ============================
  Widget _buildTransactionList(TransactionProvider provider) {
    final recentTransactions = provider.recentTransactions.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: recentTransactions.asMap().entries.map((entry) {
          final index = entry.key;
          final transaction = entry.value;
          final isLast = index == recentTransactions.length - 1;

          return Column(
            children: [
              _buildTransactionItem(transaction),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    height: 1,
                    color: Colors.grey.shade100,
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final color = transaction.isExpense ? AppColors.expense : AppColors.income;
    final iconColor = AppColors.getCategoryColor(transaction.category);

    return Dismissible(
      key: Key(transaction.id ?? '${transaction.title}-${transaction.date}'),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.expense.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete_outline_rounded,
            color: AppColors.expense.withOpacity(0.7)),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text('Delete Transaction',
                style: TextStyle(fontWeight: FontWeight.w600)),
            content: Text('Delete "${transaction.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child:
                    Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
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
        onTap: () => Navigator.pushNamed(context, '/add-transaction',
            arguments: transaction),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  transaction.isExpense
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: iconColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${transaction.category} • ${transaction.formattedDate}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount & Type
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      transaction.isExpense ? 'Expense' : 'Income',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: color,
                        letterSpacing: 0.3,
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
  // EMPTY STATE - Clean Design
  // ============================
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 52, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first transaction to get started',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/add-transaction'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
            ),
            child: const Text(
              'Add Transaction',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
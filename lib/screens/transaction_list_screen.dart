import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/utils/colors.dart';

class TransactionListScreen extends StatefulWidget {
  @override
  _TransactionListScreenState createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // 'all', 'income', 'expense'

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    
    // Filter transactions based on search and filter
    List<TransactionModel> filteredTransactions = transactionProvider.transactions.where((transaction) {
      // Search filter
      final matchesSearch = transaction.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           transaction.category.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Type filter
      final matchesType = _selectedFilter == 'all' ||
                         (_selectedFilter == 'income' && !transaction.isExpense) ||
                         (_selectedFilter == 'expense' && transaction.isExpense);
      
      return matchesSearch && matchesType;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('All Transactions'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Filter Chips
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: Text('All'),
                  selected: _selectedFilter == 'all',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = 'all';
                    });
                  },
                ),
                SizedBox(width: 8),
                FilterChip(
                  label: Text('Income'),
                  selected: _selectedFilter == 'income',
                  selectedColor: AppColors.income.withOpacity(0.2),
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = 'income';
                    });
                  },
                ),
                SizedBox(width: 8),
                FilterChip(
                  label: Text('Expense'),
                  selected: _selectedFilter == 'expense',
                  selectedColor: AppColors.expense.withOpacity(0.2),
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = 'expense';
                    });
                  },
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Transactions Count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredTransactions.length} transactions',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Total: \$${_calculateTotal(filteredTransactions).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Transactions List
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      return _buildTransactionItem(context, transaction, transactionProvider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, TransactionModel transaction, TransactionProvider provider) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.getCategoryColor(transaction.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              transaction.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
              color: AppColors.getCategoryColor(transaction.category),
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${transaction.category} • ${transaction.formattedDate}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.isExpense 
                  ? '-\$${transaction.amount.toStringAsFixed(2)}' 
                  : '+\$${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: transaction.isExpense ? AppColors.expense : AppColors.income,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, size: 18, color: Colors.grey),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/add-transaction',
                        arguments: transaction,
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 18, color: Colors.red),
                    onPressed: () {
                      _showDeleteDialog(context, transaction, provider);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TransactionModel transaction, TransactionProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Transaction'),
        content: Text('Delete "${transaction.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTransaction(transaction.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Transaction deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  double _calculateTotal(List<TransactionModel> transactions) {
    double total = 0;
    for (final transaction in transactions) {
      if (transaction.isExpense) {
        total -= transaction.amount;
      } else {
        total += transaction.amount;
      }
    }
    return total;
  }
}
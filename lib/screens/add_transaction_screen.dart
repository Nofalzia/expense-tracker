import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/utils/colors.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transactionToEdit;

  const AddTransactionScreen({Key? key, this.transactionToEdit}) : super(key: key);

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  bool _isExpense = true;
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  
  final List<String> _categories = [
    'Food', 'Shopping', 'Transport', 'Entertainment', 
    'Bills', 'Healthcare', 'Education', 'Other', 'Income'
  ];

  @override
  void initState() {
    super.initState();
    
    // If editing, populate fields
    if (widget.transactionToEdit != null) {
      final transaction = widget.transactionToEdit!;
      _titleController.text = transaction.title;
      _amountController.text = transaction.amount.toStringAsFixed(2);
      _isExpense = transaction.isExpense;
      _selectedCategory = transaction.category;
      _selectedDate = transaction.date;
      _noteController.text = transaction.note ?? '';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      
      final transaction = TransactionModel(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        category: _selectedCategory,
        isExpense: _isExpense,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );
      
      try {
        if (widget.transactionToEdit != null) {
          // Update existing transaction
          await transactionProvider.updateTransaction(
            widget.transactionToEdit!.id!,
            widget.transactionToEdit!.copyWith(
              title: _titleController.text,
              amount: double.parse(_amountController.text),
              date: _selectedDate,
              category: _selectedCategory,
              isExpense: _isExpense,
              note: _noteController.text,
            ),
          );
        } else {
          // Add new transaction
          await transactionProvider.addTransaction(transaction);
        }
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.transactionToEdit != null 
                ? 'Transaction updated successfully!' 
                : 'Transaction added successfully!'
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        
        // Navigate back
        Navigator.pop(context);
        
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          widget.transactionToEdit != null ? 'Edit Transaction' : 'Add Transaction',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: Colors.black,
        ),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(Icons.check_rounded, size: 24),
            color: AppColors.primary,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Toggle
              _buildTypeToggle(),
              const SizedBox(height: 24),
              
              // Amount Section
              _buildSectionLabel('Amount'),
              const SizedBox(height: 8),
              _buildAmountInput(),
              const SizedBox(height: 24),
              
              // Title Section
              _buildSectionLabel('Title'),
              const SizedBox(height: 8),
              _buildTitleInput(),
              const SizedBox(height: 24),
              
              // Category Section
              _buildSectionLabel('Category'),
              const SizedBox(height: 8),
              _buildCategoryDropdown(),
              const SizedBox(height: 24),
              
              // Date Section
              _buildSectionLabel('Date'),
              const SizedBox(height: 8),
              _buildDatePicker(context),
              const SizedBox(height: 24),
              
              // Notes Section
              _buildSectionLabel('Notes (Optional)'),
              const SizedBox(height: 8),
              _buildNotesInput(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFF7A7A7A),
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isExpense = true;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _isExpense ? AppColors.expense.withOpacity(0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      color: _isExpense ? AppColors.expense : const Color(0xFFACACAC),
                      size: 20,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Expense',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isExpense ? AppColors.expense : const Color(0xFFACACAC),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isExpense = false;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: !_isExpense ? AppColors.income.withOpacity(0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      color: !_isExpense ? AppColors.income : const Color(0xFFACACAC),
                      size: 20,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Income',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: !_isExpense ? AppColors.income : const Color(0xFFACACAC),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: TextFormField(
        controller: _amountController,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          prefixText: '\$ ',
          prefixStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7A7A7A),
          ),
          hintText: '0.00',
          hintStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFFACACAC),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter amount';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter valid number';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTitleInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: TextFormField(
        controller: _titleController,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          hintText: 'Enter transaction title',
          hintStyle: TextStyle(
            fontSize: 15,
            color: Color(0xFFACACAC),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter title';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF7A7A7A)),
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
          items: _categories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.getCategoryColor(category),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(category),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            Text(
              'Change',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: TextFormField(
        controller: _noteController,
        maxLines: 4,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          hintText: 'Add any additional notes...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: Color(0xFFACACAC),
          ),
        ),
      ),
    );
  }
}
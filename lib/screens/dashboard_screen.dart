import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/utils/colors.dart';
import 'package:expense_tracker/models/transaction.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      Provider.of<TransactionProvider>(context, listen: false).initialize();
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final tx = Provider.of<TransactionProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _AppBarDelegate(),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildBalanceCard(tx),
                    const SizedBox(height: 32),
                    _sectionHeader(
                      title: 'Transactions',
                      action: 'See all',
                      onTap: () => Navigator.pushNamed(context, '/transactions'),
                    ),
                    const SizedBox(height: 12),
                    tx.transactions.isEmpty
                        ? _buildEmptyState()
                        : _buildTransactionList(tx),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(auth),
    );
  }

// ================= BALANCE CARD =================
  Widget _buildBalanceCard(TransactionProvider provider) {
    final balance = provider.balance;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('assets/card.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Balance',
              style: GoogleFonts.poppins(
                fontSize: 13, // Slightly reduced for better hierarchy
                color: Colors.white70,
                fontWeight: FontWeight.w400, // Changed from 500 to 400 - metadata should disappear unless needed
              )),
          const SizedBox(height: 8),
          Text(
            '\$${balance.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 40, // Reduced from 42 for calmer feel
              fontWeight: FontWeight.w600, // Changed from 700 to 600 - numbers should feel luxurious
              color: Colors.white,
              letterSpacing: -0.8, // Numbers love tighter letter spacing
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _balanceMini('Income', provider.totalIncome,
                  Icons.arrow_downward_rounded),
              _balanceMini('Expenses', provider.totalExpenses,
                  Icons.arrow_upward_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceMini(String label, double value, IconData icon) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.poppins(
                  fontSize: 12, // Reduced from 13
                  color: Colors.white70,
                  fontWeight: FontWeight.w400, // Changed from 500 to 400 - mini labels should be lighter
                )),
            const SizedBox(height: 2),
            Text('\$${value.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600, // Kept at 600 for contrast within card
                  color: Colors.white,
                )),
          ],
        ),
      ],
    );
  }


  // ================= SECTION HEADER =================
  Widget _sectionHeader({
    required String title,
    required String action,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 22, // Reduced from 24
            fontWeight: FontWeight.w600, // Changed from 700 to 600 - respectful section divider, not headline
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: GoogleFonts.poppins(
              fontSize: 14, // Reduced from 16 for better hierarchy
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ================= TRANSACTION LIST =================
  Widget _buildTransactionList(TransactionProvider provider) {
    final items = provider.recentTransactions.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: items.map(_transactionTile).toList()),
    );
  }

  Widget _transactionTile(TransactionModel tx) {
    final color = tx.isExpense ? AppColors.expense : AppColors.income;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: color.withOpacity(0.1),
        child: Icon(
          tx.isExpense
              ? Icons.arrow_upward_rounded
              : Icons.arrow_downward_rounded,
          color: color,
          size: 20,
        ),
      ),
      title: Text(tx.title,
          // OPTIONAL: Try Inter for body text for subtle polish
          style: GoogleFonts.inter(
            fontSize: 15, // Reduced from 16
            fontWeight: FontWeight.w500, // Changed from 600 to 500 - title should be lighter
          )),
      subtitle: Text('${tx.category} • ${tx.formattedDate}',
          // OPTIONAL: Inter for metadata too
          style: GoogleFonts.inter(
            fontSize: 12, // Reduced from 13
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400, // Changed from 500 to 400 - metadata should disappear
          )),
      trailing: Text('\$${tx.amount.toStringAsFixed(2)}',
          style: GoogleFonts.poppins( // Keep Poppins for numbers
            fontWeight: FontWeight.w600, // Changed from 700 to 600
            fontSize: 16, // Kept at 16 to win hierarchy
            color: color,
          )),
    );
  }

  // ================= EMPTY STATE (CENTERED) =================
  Widget _buildEmptyState() {
    return SizedBox(
      height: 260,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text('No transactions yet',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 8),
            Text('Tap + to add your first transaction',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400, // Changed from 500 to 400
                )),
          ],
        ),
      ),
    );
  }

  // ================= BOTTOM BAR (EXACTLY 3 BUTTONS) =================
  Widget _buildBottomBar(AuthProvider auth) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // ANALYTICS button (left)
          _bottomBarItem(
            icon: Icons.analytics_outlined,
            label: 'Analytics',
            onTap: () => Navigator.pushNamed(context, '/analytics'),
          ),
          
          // ADD button (center) - slightly larger
          Container(
            margin: const EdgeInsets.only(bottom: 22),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFF4A6CF7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
                onPressed: () => Navigator.pushNamed(context, '/add-transaction'),
              ),
            ),
          ),
          
          // LOGOUT button (right)
          _bottomBarItem(
            icon: Icons.logout_rounded,
            label: 'Logout',
            onTap: () {
              auth.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }

  Widget _bottomBarItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.grey.shade700,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500, // Buttons should be medium weight
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= PERSISTENT APP BAR DELEGATE =================
class _AppBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          color: Colors.white.withOpacity(0.55),
          child: Center(
            child: Text(
              'Dashboard',
              style: GoogleFonts.poppins(
                fontSize: 40, // Reduced from 42
                fontWeight: FontWeight.w500, // Changed from 600 to 500 - big text should be lighter
                color: Colors.black87,
                letterSpacing: -0.5, // Added for premium feel
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 180;

  @override
  double get minExtent => 180;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
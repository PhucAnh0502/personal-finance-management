import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pmf_app/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:pmf_app/core/constants/app_colors.dart';
import 'package:pmf_app/data/models/transaction_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui' show ImageFilter;
import 'package:intl/intl.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen>
    with TickerProviderStateMixin {
  late AnimationController _ambientController;
  late Animation<Alignment> _bgAlignmentAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);

    _bgAlignmentAnimation = AlignmentTween(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(
        CurvedAnimation(parent: _ambientController, curve: Curves.easeInOut));

    _floatAnimation = Tween<double>(begin: -14, end: 14).animate(
        CurvedAnimation(parent: _ambientController, curve: Curves.easeInOut));

    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser!.id;
    final accountData = await client
        .from('accounts')
        .select('id')
        .eq('user_id', userId)
        .single();
    
    if (mounted) {
      context.read<TransactionBloc>().add(
            FetchTransactionsEvent(accountData['id']),
          );
    }
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _ambientController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _bgAlignmentAnimation.value,
                end: Alignment.bottomRight,
                colors: AppColors.backgroundGradient.colors,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -120,
                  right: -80,
                  child: Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.mint.withOpacity(0.45),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -140,
                  left: -60,
                  child: Transform.translate(
                    offset: Offset(0, -_floatAnimation.value),
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondaryEmerald.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: BlocBuilder<TransactionBloc, TransactionState>(
                    builder: (context, state) {
                      if (state is TransactionLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryEmerald,
                          ),
                        );
                      }

                      if (state is TransactionFailure) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'Error: ${state.error}',
                              style: const TextStyle(
                                color: AppColors.expense,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      if (state is TransactionLoaded) {
                        return _buildTransactionList(state);
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionList(TransactionLoaded state) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          floating: true,
          title: const Text(
            'Transaction History',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          centerTitle: false,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: state.transactions.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final transaction = state.transactions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildTransactionCard(transaction),
                      );
                    },
                    childCount: state.transactions.length,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(transaction) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    final isIncome = transaction.transactionType == TransactionType.income;
    
    return GestureDetector(
      onTap: () => _showTransactionDetails(transaction),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.85),
              border: Border.all(color: Colors.white.withOpacity(0.7)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isIncome 
                        ? AppColors.primaryEmerald.withOpacity(0.1)
                        : AppColors.expense.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isIncome ? AppColors.primaryEmerald : AppColors.expense,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.categoryName ?? 'Unknown',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.note ?? 'No note',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(transaction.transactionDate),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isIncome ? "+" : "-"}${transaction.amount.toStringAsFixed(0)} VND',
                  style: TextStyle(
                    color: isIncome ? AppColors.primaryEmerald : AppColors.expense,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(TransactionModel transaction) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    final isIncome = transaction.transactionType == TransactionType.income;
    final receiptUrl = transaction.imageUrl;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    transaction.categoryName ?? 'Transaction Details',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Type', isIncome ? 'Income' : 'Expense'),
                  _buildDetailRow(
                    'Amount',
                    '${isIncome ? "+" : "-"}${transaction.amount.toStringAsFixed(0)} VND',
                    valueColor: isIncome ? AppColors.primaryEmerald : AppColors.expense,
                  ),
                  _buildDetailRow('Date', dateFormat.format(transaction.transactionDate)),
                  _buildDetailRow('Note', transaction.note ?? 'No note'),
                  if (receiptUrl != null && receiptUrl.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Receipt',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        receiptUrl,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 160,
                            color: Colors.black12,
                            alignment: Alignment.center,
                            child: const Text(
                              'Failed to load receipt',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 100),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.75),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No transactions yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start tracking your spending by adding transactions',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pmf_app/bloc/budget_bloc/budget_bloc.dart';
import 'package:pmf_app/core/constants/app_colors.dart';
import 'package:pmf_app/data/models/budget_model.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
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

    // Fetch budgets for current month
    context.read<BudgetBloc>().add(FetchBudgetsEvent(DateTime.now()));
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
                  child: BlocBuilder<BudgetBloc, BudgetState>(
                    builder: (context, state) {
                      if (state is BudgetLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryEmerald,
                          ),
                        );
                      }

                      if (state is BudgetFailure) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'Error: ${state.error}',
                              style: const TextStyle(
                                  color: AppColors.expense, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      if (state is BudgetLoaded) {
                        return _buildBudgetContent(state);
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBudgetDialog,
        backgroundColor: AppColors.primaryEmerald,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Budget',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBudgetContent(BudgetLoaded state) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          floating: true,
          title: const Text(
            'Budget Management',
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
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildTotalCard(state),
              const SizedBox(height: 30),
              const Text(
                'Budget Allocations',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...state.budgets.map((budget) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildBudgetCard(budget),
                  )),
              if (state.budgets.isEmpty) _buildEmptyState(),
              const SizedBox(height: 80), // Space for FAB
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalCard(BudgetLoaded state) {
    final unallocated = state.unallocatedAmount;
    final total = state.totalCash;
    final allocated = state.totalAllocated;
    final percentageAllocated = total > 0 ? (allocated / total).clamp(0, 1) : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withOpacity(0.85),
            border: Border.all(color: Colors.white.withOpacity(0.7)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5A6B90).withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppColors.emeraldGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Total Budget',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unallocated',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${unallocated.toStringAsFixed(0)} VND',
                        style: const TextStyle(
                          color: AppColors.primaryEmerald,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total Cash',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${total.toStringAsFixed(0)} VND',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percentageAllocated.toDouble(),
                  minHeight: 12,
                  backgroundColor: AppColors.textSecondary.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryEmerald),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Allocated: ${allocated.toStringAsFixed(0)} VND (${(percentageAllocated * 100).toStringAsFixed(0)}%)',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCard(BudgetModel budget) {
    final remaining = budget.remainingAmount;
    final total = budget.limitAmount;
    final spent = budget.spentAmount;
    final percentage = budget.percentageRemaining;

    Color statusColor = AppColors.primaryEmerald;
    if (percentage < 0.15) {
      statusColor = AppColors.expense;
    } else if (percentage < 0.50) {
      statusColor = Colors.orangeAccent;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.85),
            border: Border.all(color: Colors.white.withOpacity(0.7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.category,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      budget.categoryName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    color: AppColors.primaryEmerald,
                    onPressed: () => _showEditBudgetDialog(budget),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Remaining',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${remaining.toStringAsFixed(0)} VND',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Spent / Total',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${spent.toStringAsFixed(0)} / ${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 10,
                  backgroundColor: AppColors.textSecondary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(percentage * 100).toStringAsFixed(0)}% remaining',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
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
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No budget allocations yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap "Add Budget" to create your first budget allocation',
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

  void _showAddBudgetDialog() {
    final nameController = TextEditingController();
    final limitController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 30,
                bottom: MediaQuery.of(context).viewInsets.bottom + 30,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add Budget Allocation',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: AppColors.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDialogTextField(
                      nameController,
                      'Category Name',
                      'e.g., Food, Transport',
                      TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    _buildDialogTextField(
                      limitController,
                      'Budget Limit (VND)',
                      '0.00',
                      TextInputType.number,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.primaryEmerald,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Cancel',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.primaryEmerald,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (formKey.currentState!.validate()) {
                                final name = nameController.text;
                                final limit =
                                    double.tryParse(limitController.text) ?? 0;

                                context.read<BudgetBloc>().add(
                                      AddBudgetCategoryEvent(
                                        name: name,
                                        limitAmount: limit,
                                        month: DateTime.now(),
                                      ),
                                    );

                                Navigator.pop(context);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: AppColors.emeraldGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Add Budget',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditBudgetDialog(BudgetModel budget) {
    final limitController = TextEditingController(text: budget.limitAmount.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 30,
                bottom: MediaQuery.of(context).viewInsets.bottom + 30,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Edit Budget Limit',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      budget.categoryName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDialogTextField(
                      limitController,
                      'Budget Limit',
                      'Enter new limit amount',
                      TextInputType.number,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final newLimit = double.parse(limitController.text);
                            context.read<BudgetBloc>().add(
                                  UpdateBudgetLimitEvent(
                                    categoryId: budget.categoryId,
                                    newLimit: newLimit,
                                    month: DateTime.now(),
                                  ),
                                );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryEmerald,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Update Limit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogTextField(
    TextEditingController controller,
    String label,
    String hint,
    TextInputType keyboardType,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
          : [],
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black12),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryEmerald, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field cannot be empty';
        }
        return null;
      },
    );
  }
}

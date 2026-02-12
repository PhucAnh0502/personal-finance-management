part of 'budget_bloc.dart';

@immutable
sealed class BudgetState {}

final class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final List<BudgetModel> budgets;
  final double totalAllocated;
  final double totalCash;
  final double unbudgetedSpent;

  BudgetLoaded({
    required this.budgets,
    required this.totalAllocated,
    required this.totalCash,
    required this.unbudgetedSpent,
  });

  double get unallocatedAmount => totalCash - totalAllocated - unbudgetedSpent;
}

class BudgetFailure extends BudgetState {
  final String error;
  BudgetFailure(this.error);
}

part of 'budget_bloc.dart';

@immutable
sealed class BudgetEvent {}

class FetchBudgetsEvent extends BudgetEvent {
  final DateTime month;
  FetchBudgetsEvent(this.month);
}

class AddBudgetCategoryEvent extends BudgetEvent {
  final String name;
  final double limitAmount;
  final DateTime month;

  AddBudgetCategoryEvent({
    required this.name,
    required this.limitAmount,
    required this.month,
  });
}

class UpdateBudgetLimitEvent extends BudgetEvent {
  final String categoryId;
  final double newLimit;
  final DateTime month;

  UpdateBudgetLimitEvent({
    required this.categoryId,
    required this.newLimit,
    required this.month,
  });
}

class DeleteBudgetCategoryEvent extends BudgetEvent {
  final String categoryId;
  final DateTime month;

  DeleteBudgetCategoryEvent({
    required this.categoryId,
    required this.month,
  });
}

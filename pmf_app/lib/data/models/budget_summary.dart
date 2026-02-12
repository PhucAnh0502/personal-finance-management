import 'budget_model.dart';

class BudgetSummary {
  final List<BudgetModel> budgets;
  final double unbudgetedSpent;

  BudgetSummary({
    required this.budgets,
    required this.unbudgetedSpent,
  });
}

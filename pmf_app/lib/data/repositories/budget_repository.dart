import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';
import '../models/budget_summary.dart';

class BudgetRepository {
  final _client = Supabase.instance.client;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _client.from('categories').select().eq('user_id', _client.auth.currentUser!.id);

    return (response as List).map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<BudgetSummary> getBudgetsWithSpent(DateTime month, String accountId) async {
    final userId = _client.auth.currentUser!.id;
    
    final budgetData = await _client
        .from("budgets")
        .select('*, categories(name)')
        .eq('user_id', userId)
        .eq('month_year', DateTime(month.year, month.month, 1).toIso8601String());
    
    final transactionData = await _client
        .from('transactions')
        .select('amount, category_id')
        .eq('account_id', accountId);

    final budgetList = budgetData as List;
    final transactionList = transactionData as List;
    final budgetCategoryIds = budgetList.map((b) => b['category_id']).toSet();

    double unbudgetedSpent = 0;
    for (final t in transactionList) {
      final amount = (t['amount'] as num).toDouble();
      if (amount >= 0) {
        continue;
      }
      if (!budgetCategoryIds.contains(t['category_id'])) {
        unbudgetedSpent += amount.abs();
      }
    }

    final budgets = budgetList.map((b) {
      final categoryId = b['category_id'];
      final categoryName = b['categories']['name'];
      final limit = (b['amount_limit'] as num).toDouble();
      
      double spent = 0;
      for (final t in transactionList) {
        final amount = (t['amount'] as num).toDouble();
        if (amount < 0 && t['category_id'] == categoryId) {
          spent += amount.abs();
        }
      }

      return BudgetModel(
        categoryId: categoryId,
        categoryName: categoryName,
        limitAmount: limit,
        spentAmount: spent,
      );
    }).toList();

    return BudgetSummary(
      budgets: budgets,
      unbudgetedSpent: unbudgetedSpent,
    );
  }

  Future<void> createCategoryWithBudget(String name, double limit) async {
    final userId = _client.auth.currentUser!.id;

    final categoryResponse = await _client.from('categories').insert({
      'name': name,
      'user_id': userId,
    }).select().single();

    await _client.from('budgets').insert({
      'category_id': categoryResponse['id'],
      'user_id': userId,
      'amount_limit': limit,
      'month_year': DateTime(DateTime.now().year, DateTime.now().month, 1).toIso8601String(),
    }); 
  }

  Future<void> updateBudgetLimit(String categoryId, double newLimit, DateTime month) async {
    final userId = _client.auth.currentUser!.id;
    await _client
        .from('budgets')
        .update({'amount_limit': newLimit})
        .eq('category_id', categoryId)
        .eq('user_id', userId)
        .eq('month_year', DateTime(month.year, month.month, 1).toIso8601String());
  }

  Future<void> deleteCategoryAndBudgets(String categoryId) async {
    final userId = _client.auth.currentUser!.id;

    // Remove budgets first to avoid FK constraints
    await _client
        .from('budgets')
        .delete()
        .eq('category_id', categoryId)
        .eq('user_id', userId);

    await _client
        .from('categories')
        .delete()
        .eq('id', categoryId)
        .eq('user_id', userId);
  }
}
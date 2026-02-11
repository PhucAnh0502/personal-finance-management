import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  final _client = Supabase.instance.client;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _client.from('categories').select().eq('user_id', _client.auth.currentUser!.id);

    return (response as List).map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<List<BudgetModel>> getBudgetsWithSpent(DateTime month, String accountId) async {
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

    return (budgetData as List).map((b) {
      final categoryId = b['category_id'];
      final categoryName = b['categories']['name'];
      final limit = (b['amount_limit'] as num).toDouble();
      
      double spent = 0;
      for (var t in transactionData) {
        if (t['category_id'] == categoryId) {
          spent += (t['amount'] as num).toDouble().abs();
        }
      }

      return BudgetModel(
        categoryId: categoryId,
        categoryName: categoryName,
        limitAmount: limit,
        spentAmount: spent,
      );
    }).toList();
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
}
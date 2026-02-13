import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group_model.dart';
import '../models/group_transaction_model.dart';
import '../models/category_model.dart';
import '../models/group_budget_model.dart';

class GroupRepository {
  final _client = Supabase.instance.client;

  String _formatMonthYear(DateTime month) {
    final monthStart = DateTime(month.year, month.month, 1);
    return monthStart.toIso8601String().split('T').first;
  }

  Future<List<GroupModel>> getMyGroups() async {
    final userId = _client.auth.currentUser!.id;
    final respone = await _client
        .from('group_members')
        .select('groups(*)')
        .eq('user_id', userId);

    return (respone as List)
        .map((e) => GroupModel.fromJson(e['groups']))
        .toList();
  }

  Future<void> createGroup(String name, double totalFund) async {
    final userId = _client.auth.currentUser!.id;

    final group = await _client.from('groups').insert({
      'name': name,
      'created_by': userId,
      'total_fund': totalFund,
    }).select().single();

    await _client.from('group_members').insert({
      'group_id': group['id'],
      'user_id': userId,
      'role': 'admin',
    });
  }

  Future<List<GroupTransactionModel>> getGroupTransactions(String groupId) async {
    final response = await _client
        .from('group_transactions')
        .select('*, categories(*)')
        .eq('group_id', groupId)
        .order('created_at', ascending: false);

    final rows = (response as List).cast<Map<String, dynamic>>();
    final profileIds = rows
        .map((e) => e['created_by'])
        .where((id) => id != null)
        .toSet()
        .toList();

    final Map<String, String> profileMap = {};
    if (profileIds.isNotEmpty) {
      final profileIdFilter = '(${profileIds.map((id) => id.toString()).join(',')})';
      final profiles = await _client
          .from('profiles')
          .select('id, display_name')
          .filter('id', 'in', profileIdFilter);

      for (final profile in (profiles as List)) {
        final id = profile['id']?.toString();
        if (id != null) {
          profileMap[id] = profile['display_name'] ?? 'Member';
        }
      }
    }

    return rows.map((row) {
      final creatorId = row['created_by']?.toString();
      final creatorName = creatorId != null
          ? profileMap[creatorId] ?? 'Member'
          : 'Member';
      final enriched = Map<String, dynamic>.from(row);
      enriched['profiles'] = {'display_name': creatorName};
      return GroupTransactionModel.fromJson(enriched);
    }).toList();
  }

  Future<List<GroupBudgetModel>> getGroupBudgetsForMonth(
    String groupId,
    DateTime month,
  ) async {
    final response = await _client
        .from('group_budgets')
        .select()
        .eq('group_id', groupId)
        .eq('month_year', _formatMonthYear(month));

    return (response as List)
        .map((json) => GroupBudgetModel.fromJson(json))
        .toList();
  }

  Future<List<CategoryModel>> getCategoriesForGroup(String groupId) async {
    final response = await _client
        .from('categories')
        .select()
        .or('group_id.eq.$groupId,and(user_id.is.null,group_id.is.null)');
    return (response as List).map((json) => CategoryModel.fromJson(json)).toList();
  }

  Future<void> addGroupTransaction({
    required String groupId,
    required double amount,
    required String categoryId,
    String? note,
    String? imageProof,
  }) async {
    await _client.from('group_transactions').insert({
      'group_id': groupId,
      'amount': amount,
      'category_id': categoryId,
      'created_by': _client.auth.currentUser!.id,
      'note': note,
      'image_proof': imageProof,
    });
  }

  Future<void> updateGroupFund(String groupId, double totalFund) async {
    await _client
        .from('groups')
        .update({'total_fund': totalFund})
        .eq('id', groupId);
  }

  Future<void> createGroupCategoryWithBudget({
    required String groupId,
    required String name,
    required double limitAmount,
    String? color,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final month = DateTime(DateTime.now().year, DateTime.now().month, 1);

    final categoryResponse = await _client.from('categories').insert({
      'name': name,
      'group_id': groupId,
      'color': color ?? '#10B981',
    }).select().single();

    await _client.from('group_budgets').insert({
      'group_id': groupId,
      'category_id': categoryResponse['id'],
      'amount_limit': limitAmount,
      'month_year': _formatMonthYear(month),
      'created_by': userId,
    });
  }

  Future<void> deleteGroup(String groupId) async {
    await _client.from('group_transactions').delete().eq('group_id', groupId);
    await _client.from('group_members').delete().eq('group_id', groupId);
    await _client.from('groups').delete().eq('id', groupId);
  }

  Future<void> updateGroupTransaction({
    required String transactionId,
    required double amount,
    required String categoryId,
    String? note,
    String? imageProof,
  }) async {
    await _client.from('group_transactions').update({
      'amount': amount,
      'category_id': categoryId,
      'note': note,
      'image_proof': imageProof,
    }).eq('id', transactionId);
  }

  Future<void> deleteGroupTransaction(String transactionId) async {
    await _client
        .from('group_transactions')
        .delete()
        .eq('id', transactionId);
  }

  Future<GroupModel> getGroupById(String groupId) async {
    final response = await _client
        .from('groups')
        .select()
        .eq('id', groupId)
        .single();
    return GroupModel.fromJson(response);
  }

  Future<void> updateGroupCategory({
    required String categoryId,
    String? name,
    double? allocatedAmount,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (allocatedAmount != null) updates['allocated_amount'] = allocatedAmount;
    
    await _client
        .from('categories')
        .update(updates)
        .eq('id', categoryId);
  }

  Future<void> deleteGroupCategory(String categoryId) async {
    await _client
      .from('group_transactions')
      .update({'category_id': null})
      .eq('category_id', categoryId);

    await _client
      .from('group_budgets')
      .delete()
      .eq('category_id', categoryId);

    await _client
      .from('categories')
      .delete()
      .eq('id', categoryId);
  }
}
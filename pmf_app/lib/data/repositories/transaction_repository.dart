import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final _client = Supabase.instance.client;

  Future<List<TransactionModel>> getTransactions(String accountId) async {
    final response = await _client
        .from('transactions')
        .select('*, categories(name)')
        .eq('account_id', accountId)
        .order('transaction_date', ascending: false);

    return (response as List)
        .map((e) => TransactionModel.fromJson(e))
        .toList();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _client.from('transactions').insert(transaction.toJson());
    
    // Update account balance for income transactions
    if (transaction.transactionType == TransactionType.income) {
      final accountData = await _client
          .from('accounts')
          .select('balance')
          .eq('id', transaction.accountId)
          .single();
      
      final currentBalance = (accountData['balance'] as num).toDouble();
      await _client
          .from('accounts')
          .update({'balance': currentBalance + transaction.amount})
          .eq('id', transaction.accountId);
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _client.from('transactions').delete().eq('id', transactionId);
  }

  Future<void> updateTransaction(
      String transactionId, TransactionModel transaction) async {
    await _client
        .from('transactions')
        .update(transaction.toJson())
        .eq('id', transactionId);
  }
}

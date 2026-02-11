part of 'transaction_bloc.dart';

@immutable
sealed class TransactionEvent {}

class FetchTransactionsEvent extends TransactionEvent {
  final String accountId;
  FetchTransactionsEvent(this.accountId);
}

class AddTransactionEvent extends TransactionEvent {
  final TransactionModel transaction;
  AddTransactionEvent(this.transaction);
}

class DeleteTransactionEvent extends TransactionEvent {
  final String transactionId;
  final String accountId;
  DeleteTransactionEvent(this.transactionId, this.accountId);
}

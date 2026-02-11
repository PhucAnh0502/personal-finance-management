part of 'transaction_bloc.dart';

@immutable
sealed class TransactionState {}

final class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;

  TransactionLoaded({required this.transactions});
}

class TransactionFailure extends TransactionState {
  final String error;
  TransactionFailure(this.error);
}

class TransactionSuccess extends TransactionState {
  final String message;
  TransactionSuccess(this.message);
}

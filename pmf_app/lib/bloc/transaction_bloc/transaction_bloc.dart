import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pmf_app/data/models/transaction_model.dart';
import 'package:pmf_app/data/repositories/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository transactionRepository;

  TransactionBloc({required this.transactionRepository})
      : super(TransactionInitial()) {
    on<FetchTransactionsEvent>(_onFetchTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
  }

  Future<void> _onFetchTransactions(
      FetchTransactionsEvent event, emit) async {
    emit(TransactionLoading());
    try {
      final transactions =
          await transactionRepository.getTransactions(event.accountId);
      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      emit(TransactionFailure(e.toString()));
    }
  }

  Future<void> _onAddTransaction(AddTransactionEvent event, emit) async {
    try {
      await transactionRepository.addTransaction(event.transaction);
      emit(TransactionSuccess('Transaction added successfully'));
      add(FetchTransactionsEvent(event.transaction.accountId));
    } catch (e) {
      emit(TransactionFailure(e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(DeleteTransactionEvent event, emit) async {
    try {
      await transactionRepository.deleteTransaction(event.transactionId);
      emit(TransactionSuccess('Transaction deleted'));
      add(FetchTransactionsEvent(event.accountId));
    } catch (e) {
      emit(TransactionFailure(e.toString()));
    }
  }
}

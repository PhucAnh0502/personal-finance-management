import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pmf_app/data/models/budget_model.dart';
import 'package:pmf_app/data/repositories/budget_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'budget_event.dart';
part 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository budgetRepository;
  final _client = Supabase.instance.client;

  BudgetBloc({required this.budgetRepository}) : super(BudgetInitial()) {
    on<FetchBudgetsEvent>(_onFetchBudgets);
    on<AddBudgetCategoryEvent>(_onAddBudget);
    on<UpdateBudgetLimitEvent>(_onUpdateBudgetLimit);
    on<DeleteBudgetCategoryEvent>(_onDeleteBudgetCategory);
  }

  Future<void> _onFetchBudgets(FetchBudgetsEvent event, emit) async {
    emit(BudgetLoading());
    try {
      final userId = _client.auth.currentUser!.id;

      final accountData = await _client
          .from('accounts')
          .select('id, balance')
          .eq('user_id', userId)
          .single();

      double totalCash = (accountData['balance'] as num).toDouble();
      String accountId = accountData['id'];
      
      final summary = await budgetRepository.getBudgetsWithSpent(event.month, accountId);

      final budgets = summary.budgets;
      double totalAllocated = budgets.fold(0, (sum, item) => sum + item.limitAmount);
      emit(BudgetLoaded(
        budgets: budgets,
        totalAllocated: totalAllocated,
        totalCash: totalCash,
        unbudgetedSpent: summary.unbudgetedSpent,
      ));
    } catch (e) {
      emit(BudgetFailure(e.toString()));
    }
  }

  Future<void> _onAddBudget(AddBudgetCategoryEvent event, emit) async {
    try {
      await budgetRepository.createCategoryWithBudget(event.name, event.limitAmount);
      
      add(FetchBudgetsEvent(event.month));
    } catch (e) {
      emit(BudgetFailure(e.toString()));
    }
  }

  Future<void> _onUpdateBudgetLimit(UpdateBudgetLimitEvent event, emit) async {
    try {
      await budgetRepository.updateBudgetLimit(event.categoryId, event.newLimit, event.month);
      
      add(FetchBudgetsEvent(event.month));
    } catch (e) {
      emit(BudgetFailure(e.toString()));
    }
  }

  Future<void> _onDeleteBudgetCategory(DeleteBudgetCategoryEvent event, emit) async {
    try {
      await budgetRepository.deleteCategoryAndBudgets(event.categoryId);
      
      add(FetchBudgetsEvent(event.month));
    } catch (e) {
      emit(BudgetFailure(e.toString()));
    }
  }
}

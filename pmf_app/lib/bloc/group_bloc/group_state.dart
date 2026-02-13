part of 'group_bloc.dart';

@immutable
sealed class GroupState extends Equatable{
  @override
  List<Object?> get props => [];
}

final class GroupInitial extends GroupState {}
final class GroupLoading extends GroupState {}
final class GroupSuccess extends GroupState {}

class GroupLoaded extends GroupState {
  final List<GroupModel> groups;
  GroupLoaded(this.groups);
  @override
  List<Object?> get props => [groups];
}

class GroupDetailLoaded extends GroupState {
  final List<GroupTransactionModel> transactions;
  final List<CategoryModel> categories;
  final List<GroupBudgetModel> budgets;
  GroupDetailLoaded([
    this.transactions = const [],
    this.categories = const [],
    this.budgets = const [],
  ]);
  @override
  List<Object?> get props => [transactions, categories, budgets];
}

class GroupError extends GroupState {
  final String message;
  GroupError(this.message);
  @override
  List<Object?> get props => [message];
}



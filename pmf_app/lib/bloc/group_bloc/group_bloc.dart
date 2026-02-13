import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pmf_app/data/models/category_model.dart';
import 'package:pmf_app/data/models/group_model.dart';
import 'package:pmf_app/data/models/group_transaction_model.dart';
import 'package:pmf_app/data/models/group_budget_model.dart';
import 'package:pmf_app/data/repositories/group_repository.dart';

part 'group_event.dart';
part 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupRepository groupRepository;
  GroupBloc(this.groupRepository) : super(GroupInitial()) {
    on<FetchGroups>((event, emit) async {
      emit(GroupLoading());
      try {
        final groups = await groupRepository.getMyGroups();
        emit(GroupLoaded(groups));
      } catch (e) {
        emit(GroupError(e.toString()));
      }
    });

    on<CreateGroup>((event, emit) async {
      try {
        await groupRepository.createGroup(event.name, event.totalFund);
        add(FetchGroups());
      } catch (e) {
        emit(GroupError(e.toString()));
      }
    });

    on<FetchGroupDetail>((event, emit) async {
      emit(GroupLoading());
      try {
        final txns = await groupRepository.getGroupTransactions(event.groupId);
        final cats = await groupRepository.getCategoriesForGroup(event.groupId);
        final budgets = await groupRepository.getGroupBudgetsForMonth(
          event.groupId,
          DateTime.now(),
        );
        emit(GroupDetailLoaded(txns, cats, budgets));
      } catch (e) {
        emit(GroupError(e.toString()));
      }
    });

    on<AddGroupExpense>((event, emit) async {
      emit(GroupLoading());
      try {
        await groupRepository.addGroupTransaction(
          groupId: event.groupId,
          amount: event.amount,
          categoryId: event.categoryId,
          note: event.note,
          imageProof: event.imageProof,
        );
        add(FetchGroupDetail(event.groupId));
        add(FetchGroups());
      } catch (e) {
        emit(GroupError(e.toString()));
      }
    });

    on<UpdateGroupFund>((event, emit) async {
      emit(GroupLoading());
      try {
        await groupRepository.updateGroupFund(event.groupId, event.totalFund);
        add(FetchGroupDetail(event.groupId));
        add(FetchGroups());
      } catch (e) {
        emit(GroupError(e.toString()));
      }
    });

    on<CreateGroupCategory>((event, emit) async {
      emit(GroupLoading());
      try {
        await groupRepository.createGroupCategoryWithBudget(
          groupId: event.groupId,
          name: event.name,
          limitAmount: event.limitAmount,
          color: event.color,
        );
        add(FetchGroupDetail(event.groupId));
      } catch (e) {
        emit(GroupError(e.toString()));
      }
    });

    on<DeleteGroup>((event, emit) async {
      emit(GroupLoading());
      try {
        await groupRepository.deleteGroup(event.groupId);
        add(FetchGroups());
      } catch (e) {
        emit(GroupError(e.toString()));
      }
    });

    on<UpdateGroupExpense>((event, emit) async {
      emit(GroupLoading());
      try {
        await groupRepository.updateGroupTransaction(
          transactionId: event.transactionId,
          amount: event.amount,
          categoryId: event.categoryId,
          note: event.note,
          imageProof: event.imageProof,
        );
        add(FetchGroupDetail(event.groupId));
        add(FetchGroups());
      } catch (e) {
        emit(GroupError(e.toString()));
      }
    });

    on<DeleteGroupExpense>((event, emit) async {
      emit(GroupLoading());
      try {
        await groupRepository.deleteGroupTransaction(event.transactionId);
        add(FetchGroupDetail(event.groupId));
        add(FetchGroups());
      } catch (e) {
        emit(GroupError(e.toString()));
      }
    });

    on<UpdateGroupCategory>((event, emit) async {
      emit(GroupLoading());
      try {
        await groupRepository.updateGroupCategory(
          categoryId: event.categoryId,
          name: event.name,
          allocatedAmount: event.allocatedAmount,
        );
        add(FetchGroupDetail(event.groupId));
      } catch (e) {
        emit(GroupError(e.toString()));
      }
    });

    on<DeleteGroupCategory>((event, emit) async {
      emit(GroupLoading());
      try {
        await groupRepository.deleteGroupCategory(event.categoryId);
        add(FetchGroupDetail(event.groupId));
      } catch (e) {
        emit(GroupError(e.toString()));
      }
    });
  }
}

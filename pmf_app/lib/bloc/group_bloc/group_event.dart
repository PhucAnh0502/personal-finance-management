part of 'group_bloc.dart';

@immutable
sealed class GroupEvent {}

class FetchGroups extends GroupEvent {}

class CreateGroup extends GroupEvent {
  final String name;
  final double totalFund;
  CreateGroup(this.name, this.totalFund);
}

class FetchGroupDetail extends GroupEvent {
  final String groupId;
  FetchGroupDetail(this.groupId);
}

class AddGroupExpense extends GroupEvent {
  final String groupId;
  final double amount;
  final String categoryId;
  final String? note;
  final String? imageProof;

  AddGroupExpense({
    required this.groupId,
    required this.amount,
    required this.categoryId,
    this.note,
    this.imageProof,
  });
}

class UpdateGroupFund extends GroupEvent {
  final String groupId;
  final double totalFund;

  UpdateGroupFund({
    required this.groupId,
    required this.totalFund,
  });
}

class CreateGroupCategory extends GroupEvent {
  final String groupId;
  final String name;
  final double limitAmount;
  final String? color;

  CreateGroupCategory({
    required this.groupId,
    required this.name,
    required this.limitAmount,
    this.color,
  });
}

class DeleteGroup extends GroupEvent {
  final String groupId;

  DeleteGroup(this.groupId);
}

class UpdateGroupExpense extends GroupEvent {
  final String transactionId;
  final String groupId;
  final double amount;
  final String categoryId;
  final String? note;
  final String? imageProof;

  UpdateGroupExpense({
    required this.transactionId,
    required this.groupId,
    required this.amount,
    required this.categoryId,
    this.note,
    this.imageProof,
  });
}

class DeleteGroupExpense extends GroupEvent {
  final String transactionId;
  final String groupId;

  DeleteGroupExpense({
    required this.transactionId,
    required this.groupId,
  });
}

class UpdateGroupCategory extends GroupEvent {
  final String categoryId;
  final String groupId;
  final String? name;
  final double? allocatedAmount;

  UpdateGroupCategory({
    required this.categoryId,
    required this.groupId,
    this.name,
    this.allocatedAmount,
  });
}

class DeleteGroupCategory extends GroupEvent {
  final String categoryId;
  final String groupId;

  DeleteGroupCategory({
    required this.categoryId,
    required this.groupId,
  });
}

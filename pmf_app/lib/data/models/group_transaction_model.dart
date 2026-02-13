import 'category_model.dart';

class GroupTransactionModel {
  final String id;
  final String groupId;
  final double amount;
  final String? note;
  final String? imageProof;
  final DateTime createdAt;
  final String creatorName;
  final CategoryModel? category;

  GroupTransactionModel({
    required this.id,
    required this.groupId,
    required this.amount,
    this.note,
    this.imageProof,
    required this.createdAt,
    required this.creatorName,
    this.category,
  });

  factory GroupTransactionModel.fromJson(Map<String, dynamic> json) {
    return GroupTransactionModel(
      id: json['id'],
      groupId: json['group_id'],
      amount: (json['amount'] ?? 0).toDouble(),
      note: json['note'],
      imageProof: json['image_proof'],
      createdAt: DateTime.parse(json['created_at']),
      creatorName: json['profiles']?['display_name'] ?? 'Member',
      category: json['categories'] != null
          ? CategoryModel.fromJson(json['categories'])
          : null,
    );
  }
}
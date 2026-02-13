class GroupBudgetModel {
  final String id;
  final String groupId;
  final String categoryId;
  final double amountLimit;
  final DateTime monthYear;

  GroupBudgetModel({
    required this.id,
    required this.groupId,
    required this.categoryId,
    required this.amountLimit,
    required this.monthYear,
  });

  factory GroupBudgetModel.fromJson(Map<String, dynamic> json) {
    return GroupBudgetModel(
      id: json['id']?.toString() ?? '',
      groupId: json['group_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      amountLimit: (json['amount_limit'] as num?)?.toDouble() ?? 0.0,
      monthYear: DateTime.parse(json['month_year'] as String),
    );
  }
}
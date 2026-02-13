class GroupModel {
  final String id;
  final String name;
  final String? createdBy;
  final double totalFund;

  GroupModel({
    required this.id,
    required this.name,
    this.createdBy,
    required this.totalFund,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json){
    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdBy: json['created_by'] as String?,
      totalFund: (json['total_fund'] ?? 0).toDouble(),
    );
  }
}
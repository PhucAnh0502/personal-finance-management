enum BankNotificationType {
  income,
  expense,
  unknown,
}

class BankNotificationModel {
  final String id;
  final String? userId;
  final String packageName;
  final String title;
  final String body;
  final double amount;
  final BankNotificationType type;
  final bool isRead;
  final DateTime createdAt;

  BankNotificationModel({
    required this.id,
    this.userId,
    required this.packageName,
    required this.title,
    required this.body,
    required this.amount,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  factory BankNotificationModel.fromJson(Map<String, dynamic> json) {
    return BankNotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      packageName: json['package_name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      type: _typeFromString(json['type']?.toString()),
      isRead: json['is_read'] == true,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'user_id': userId,
      'package_name': packageName,
      'title': title,
      'body': body,
      'amount': amount,
      'type': type.name,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static BankNotificationType _typeFromString(String? value) {
    switch (value) {
      case 'income':
        return BankNotificationType.income;
      case 'expense':
        return BankNotificationType.expense;
      case 'unknown':
      default:
        return BankNotificationType.unknown;
    }
  }
}

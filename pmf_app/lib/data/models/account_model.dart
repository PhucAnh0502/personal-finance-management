class AccountModel {
  final String id;
  final String userId;
  final double balance;

  AccountModel({
    required this.id,
    required this.userId,
    required this.balance,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'balance': balance,
    };
  }
}

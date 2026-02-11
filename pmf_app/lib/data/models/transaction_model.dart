enum TransactionType { income, expense }

class TransactionModel {
  final String? id;
  final String accountId;
  final String categoryId;
  final double amount;
  final String? note;
  final DateTime transactionDate;
  final String? imageUrl;
  final String? categoryName;
  final TransactionType transactionType;

  TransactionModel({
    this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    this.note,
    required this.transactionDate,
    this.imageUrl,
    this.categoryName,
    this.transactionType = TransactionType.expense,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      accountId: json['account_id'],
      categoryId: json['category_id'],
      amount: (json['amount'] as num).toDouble().abs(),
      note: json['note'],
      transactionDate: DateTime.parse(json['transaction_date']),
      imageUrl: json['image_url'],
      categoryName: json['categories']?['name'],
      transactionType: (json['amount'] as num).toDouble() >= 0 
          ? TransactionType.income 
          : TransactionType.expense,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'category_id': categoryId,
      'amount': transactionType == TransactionType.income ? amount : -amount,
      'note': note,
      'transaction_date': transactionDate.toIso8601String(),
      'image_url': imageUrl,
    };
  }
}

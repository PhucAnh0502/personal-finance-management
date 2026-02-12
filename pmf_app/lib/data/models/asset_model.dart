class AssetModel {
  final String? id;
  final String assetName;
  final String assetType;
  final double quantity;
  final double purchasePrice;
  final double currentPrice;

  AssetModel({
    this.id,
    required this.assetName,
    required this.assetType,
    required this.quantity,
    required this.purchasePrice,
    this.currentPrice = 0.0,
  });

  double get totalValue => quantity * currentPrice;

  double get profitLoss => ((currentPrice - purchasePrice) / purchasePrice) * 100;

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'],
      assetName: json['asset_name'],
      assetType: json['asset_type'],
      quantity: (json['quantity'] as num).toDouble(),
      purchasePrice: (json['purchase_price'] as num).toDouble(),
      currentPrice: json['current_price'] != null ? (json['current_price'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson(String userId) {
    return {
      'user_id': userId,
      'asset_name': assetName,
      'asset_type': assetType,
      'quantity': quantity,
      'purchase_price': purchasePrice,
      'current_price': currentPrice,
    };
  }
}
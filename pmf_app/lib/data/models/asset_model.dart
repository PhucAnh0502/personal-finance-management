class AssetModel {
  final String assetName;
  final String assetType;
  final double quantity;
  final double purchasePrice;

  AssetModel({
    required this.assetName,
    required this.assetType,
    required this.quantity,
    required this.purchasePrice,
  });

  Map<String, dynamic> toJson(String userId) {
    return {
      'user_id': userId,
      'asset_name': assetName,
      'asset_type': assetType,
      'quantity': quantity,
      'purchase_price': purchasePrice,
      // current_price can be defaulted to purchase_price on creation
      'current_price': purchasePrice, 
    };
  }
}
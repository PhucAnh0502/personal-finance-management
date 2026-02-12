import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/asset_model.dart';

class AssetRepository {
  final _client = Supabase.instance.client;

  Future<List<AssetModel>> getAssets() async {
    final response = await _client.from('assets').select().eq('user_id', _client.auth.currentUser!.id);

    return (response as List).map((json) => AssetModel.fromJson(json)).toList();
  }

  Future<void> addAsset(AssetModel asset) async {
    await _client.from('assets').insert(asset.toJson(_client.auth.currentUser!.id));
  }

  Future<void> updateAsset(AssetModel asset, String assetId) async {
    await _client.from('assets').update(asset.toJson(_client.auth.currentUser!.id)).eq('id', assetId);
  }

  Future<void> deleteAsset(String assetId) async {
    await _client.from('assets').delete().eq('id', assetId);
  }
}
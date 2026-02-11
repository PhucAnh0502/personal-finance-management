import 'package:pmf_app/data/models/asset_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SetupRepository {
  final SupabaseClient _client;

  SetupRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<void> completeSetup({
    required String displayName,
    required String avatarUrl,
    required double accountBalance,
    required List<AssetModel> assets,
  }) async {
    try {
      final userId = _client.auth.currentUser!.id;

      // Step 1: Update profile
      await _client.from('profiles').upsert({
        'id': userId,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'has_finished_setup': true,
      });

      // Step 2: Create or update the single account for the user
      await _client.from('accounts').upsert({
        'user_id': userId,
        'balance': accountBalance,
      });

      // Step 3: Insert all the assets the user created
      if (assets.isNotEmpty) {
        final assetsJson =
            assets.map((asset) => asset.toJson(userId)).toList();
        await _client.from('assets').insert(assetsJson);
      }
    } catch (e) {
      // Re-throw the exception to be handled by the BLoC
      throw Exception('Failed to complete setup: $e');
    }
  }
}

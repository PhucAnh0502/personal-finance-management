import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class UserRepository {
  final _client = Supabase.instance.client;

  Future<ProfileModel> getProfile() async {
    try {
      final userId = _client.auth.currentUser!.id;
      final authUser = _client.auth.currentUser;
      
      debugPrint('[UserRepository] Fetching profile for userId: $userId');
      debugPrint('[UserRepository] Auth user email: ${authUser?.email}');
      
      try {
        // Try to fetch from profiles table
        final data = await _client.from('profiles').select().eq('id', userId).single();
        debugPrint('[UserRepository] Profile data fetched: $data');
        debugPrint('[UserRepository] Profile keys: ${data.keys.toList()}');
        return ProfileModel.fromJson(data);
      } catch (e) {
        debugPrint('[UserRepository] Error fetching from profiles table: $e');
        debugPrint('[UserRepository] Error type: ${e.runtimeType}');
        
        // If profile doesn't exist, create default profile from auth user
        debugPrint('[UserRepository] Creating default profile from auth user');
        final displayName = authUser?.userMetadata?['display_name'] ?? 
                           authUser?.userMetadata?['name'] ?? 
                           authUser?.email?.split('@').first ?? 
                           'User';
        
        final defaultProfile = {
          'id': userId,
          'display_name': displayName,
          'avatar_url': authUser?.userMetadata?['avatar_url'] ?? authUser?.userMetadata?['picture'],
          'has_finished_setup': false,
        };
        
        debugPrint('[UserRepository] Default profile data: $defaultProfile');
        
        // Try to insert default profile
        try {
          await _client.from('profiles').insert(defaultProfile);
          debugPrint('[UserRepository] Default profile created successfully');
        } catch (insertError) {
          debugPrint('[UserRepository] Error creating default profile: $insertError');
          // Return default profile even if insert fails
        }
        
        return ProfileModel.fromJson(defaultProfile);
      }
    } catch (e) {
      debugPrint('[UserRepository] Unexpected error in getProfile: $e');
      debugPrint('[UserRepository] Stack trace: ${e}');
      rethrow;
    }
  }

  Future<void> updateBasicInfo(String name, String avatarPath) async {
    try {
      final userId = _client.auth.currentUser!.id;
      debugPrint('[UserRepository] Updating profile: name=$name, avatarPath=$avatarPath');
      
      await _client.from('profiles').update({
        'display_name': name,
        'avatar_url': avatarPath,
      }).eq('id', userId);
      
      debugPrint('[UserRepository] Profile updated successfully');
    } catch (e) {
      debugPrint('[UserRepository] Error updating profile: $e');
      rethrow;
    }
  }
}
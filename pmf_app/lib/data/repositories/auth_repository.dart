import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class AuthRepository {
    final _client = supa.Supabase.instance.client;

    Stream<supa.AuthState> get authStateChanges => _client.auth.onAuthStateChange;

    Future<supa.AuthResponse> signUp({required String email, required String password}) async {
        return await _client.auth.signUp(email: email, password: password);
    }

    Future<supa.AuthResponse> signIn({required String email, required String password}) async {
        return await _client.auth.signInWithPassword(email: email, password: password);
    }

    Future<void> signInWithGoogle() async {
        await _client.auth.signInWithOAuth(
            supa.OAuthProvider.google,
            redirectTo: 'io.supabase.pmfapp://login-callback',
        );
    }

    Future<void> signOut() async {
        await _client.auth.signOut();
    }

    Future<void> resetPassword({required String email}) async {
        await _client.auth.resetPasswordForEmail(
            email,
            redirectTo: 'io.supabase.pmfapp://login-callback',
        );
    }

    Future<void> updatePasswordWithTokens({
        required String accessToken,
        required String refreshToken,
        required String newPassword,
    }) async {
        final response = await _client.auth.setSession(refreshToken);
        if (response.session == null) {
            throw Exception('Invalid or expired recovery link.');
        }
        await _client.auth.updateUser(
            supa.UserAttributes(password: newPassword),
        );
        await _client.auth.signOut();
    }

    supa.User? get currentUser => _client.auth.currentUser;

    Future<void> checkAndCreateUserProfile() async {
        final user = _client.auth.currentUser;
        if (user == null) return;

        try {
            await _client.from('profiles').select('id').eq('id', user.id).single();
        } catch (e) {
            if (e is supa.PostgrestException && e.code == 'PGRST116') {
                await _client.from('profiles').insert({
                    'id': user.id,
                    'has_finished_setup': false,
                });
            } else {
                rethrow;
            }
        }
    }

    Future<bool> hasFinishedSetup() async {
        final userId = _client.auth.currentUser?.id;
        if (userId == null) {
            return false;
        }
        try {
            final response = await _client
                .from('profiles')
                .select('has_finished_setup')
                .eq('id', userId)
                .single();
            
            return response['has_finished_setup'] ?? false;
        } catch (e) {
            return false;
        }
    }
}
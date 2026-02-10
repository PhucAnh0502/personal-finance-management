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
}
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;
  late final StreamSubscription<supa.AuthState> _authSubscription;

  AuthBloc(this._repo) : super(AuthInitial()) {
    _authSubscription = _repo.authStateChanges.listen((state) {
      final user = state.session?.user;
      if (user != null) {
        add(AuthUserChanged(user.id));
      } else {
        add(AuthUserSignedOut());
      }
    });

    on<AuthCheckRequested>((event, emit) async {
      final user = _repo.currentUser;
      if(user != null) {
        final hasFinishedSetup = await _repo.hasFinishedSetup();
        emit(Authenticated(userId: user.id, hasFinishedSetup: hasFinishedSetup));
      } else {
        emit(Unauthenticated());
      }
    });

    on<AuthUserChanged>((event, emit) async {
      await _repo.checkAndCreateUserProfile();
      final hasFinishedSetup = await _repo.hasFinishedSetup();
      emit(Authenticated(userId: event.userId, hasFinishedSetup: hasFinishedSetup));
    });

    on<AuthUserSignedOut>((event, emit) {
      emit(Unauthenticated());
    });

    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        await _repo.signIn(email: event.email, password: event.password);
        final user = _repo.currentUser;
        if (user != null) {
          final hasFinishedSetup = await _repo.hasFinishedSetup();
          emit(Authenticated(userId: user.id, hasFinishedSetup: hasFinishedSetup));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<SignUpSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final response =
            await _repo.signUp(email: event.email, password: event.password);
        final user = response.user ?? _repo.currentUser;
        if (user != null) {
          await _repo.checkAndCreateUserProfile();
          final hasFinishedSetup = await _repo.hasFinishedSetup();
          emit(Authenticated(userId: user.id, hasFinishedSetup: hasFinishedSetup));
        } else {
          emit(AuthMessage('Sign up completed. Please sign in to continue.'));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<ForgotPasswordSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        await _repo.resetPassword(email: event.email);
        emit(AuthMessage('Password reset link sent. Check your email.'));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<GoogleLoginPressed>((event, emit) async {
      emit(AuthLoading());
      try {
        await _repo.signInWithGoogle();
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await _repo.signOut();
      emit(Unauthenticated());
    });

    on<ResetPasswordSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        await _repo.updatePasswordWithTokens(
          accessToken: event.accessToken,
          refreshToken: event.refreshToken,
          newPassword: event.newPassword,
        );
        emit(AuthMessage('Password updated. Please sign in again.'));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}

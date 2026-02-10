part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}
class AuthCheckRequested extends AuthEvent {}
class LoginSubmitted extends AuthEvent {
  final String email, password;
  LoginSubmitted(this.email, this.password);
}
class SignUpSubmitted extends AuthEvent {
  final String email, password;
  SignUpSubmitted(this.email, this.password);
}
class ForgotPasswordSubmitted extends AuthEvent {
  final String email;
  ForgotPasswordSubmitted(this.email);
}
class GoogleLoginPressed extends AuthEvent {}
class LogoutRequested extends AuthEvent {}
class AuthUserChanged extends AuthEvent {
  final String userId;
  AuthUserChanged(this.userId);
}
class AuthUserSignedOut extends AuthEvent {}
class ResetPasswordSubmitted extends AuthEvent {
  final String accessToken;
  final String refreshToken;
  final String newPassword;
  ResetPasswordSubmitted(this.accessToken, this.refreshToken, this.newPassword);
}

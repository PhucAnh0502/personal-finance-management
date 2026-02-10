part of 'auth_bloc.dart';

@immutable
sealed class AuthState extends Equatable{
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final String userId;
  Authenticated(this.userId);
  @override
  List<Object?> get props => [userId];
}
class Unauthenticated extends AuthState {}
class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
  @override
  List<Object?> get props => [error];
}

class AuthMessage extends AuthState {
  final String message;
  AuthMessage(this.message);
  @override
  List<Object?> get props => [message];
}

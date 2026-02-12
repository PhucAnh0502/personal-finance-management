part of 'profile_bloc.dart';

@immutable
sealed class ProfileState extends Equatable{
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {}
final class ProfileLoading extends ProfileState {}
final class ProfileLoaded extends ProfileState {
  final ProfileModel profile;
  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}
final class ProfileUpdating extends ProfileState {}
final class ProfileUpdateSuccess extends ProfileState {
  final String message;
  const ProfileUpdateSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
final class ProfileError extends ProfileState {
  final String error;
  const ProfileError(this.error);
  @override
  List<Object?> get props => [error];
}

part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class LoadProfile extends ProfileEvent {}
class UpdateProfile extends ProfileEvent {
  final String name;
  final String avatar;

  UpdateProfile(this.name, this.avatar);
}

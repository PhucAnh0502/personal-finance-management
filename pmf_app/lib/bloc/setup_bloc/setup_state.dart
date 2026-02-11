part of 'setup_bloc.dart';

@immutable
sealed class SetupState extends Equatable{
  @override
  List<Object?> get props => [];
}

final class SetupInitial extends SetupState {}
final class SetupLoading extends SetupState {}
final class SetupSuccess extends SetupState {}
final class SetupFailure extends SetupState {
  final String error;
  SetupFailure(this.error);

  @override
  List<Object?> get props => [error];
}

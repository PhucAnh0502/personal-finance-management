part of 'setup_bloc.dart';

@immutable
sealed class SetupEvent {}

class SetupSubmitted extends SetupEvent {
  final String displayName;
  final String avatarUrl;
  final double accountBalance;
  final List<AssetModel> assets;

  SetupSubmitted({
    required this.displayName,
    required this.avatarUrl,
    required this.accountBalance,
    required this.assets,
  });
}

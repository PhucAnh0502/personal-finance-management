part of 'asset_bloc.dart';

@immutable
sealed class AssetState extends Equatable {
  const AssetState();

  @override
  List<Object?> get props => [];
}

final class AssetInitial extends AssetState {}
final class AssetLoading extends AssetState {}
final class AssetLoaded extends AssetState {
  final List<AssetModel> assets;
  final double totalValue;

  const AssetLoaded({required this.assets, required this.totalValue});

  @override
  List<Object?> get props => [assets, totalValue];
}
final class AssetError extends AssetState {
  final String error;

  const AssetError(this.error);

  @override
  List<Object?> get props => [error];
}

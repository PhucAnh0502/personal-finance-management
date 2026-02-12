part of 'asset_bloc.dart';

@immutable
sealed class AssetEvent extends Equatable {
  const AssetEvent();

  @override
  List<Object?> get props => [];
}

class FetchAssetEvent extends AssetEvent {}
class AddAssetEvent extends AssetEvent {
  final AssetModel asset;

  const AddAssetEvent(this.asset);

  @override
  List<Object?> get props => [asset];
}
class UpdateAssetEvent extends AssetEvent {
  final AssetModel asset;
  final String assetId;
  const UpdateAssetEvent(this.asset, this.assetId);
  @override
  List<Object?> get props => [asset, assetId];
}
class DeleteAssetEvent extends AssetEvent {
  final String assetId;
  const DeleteAssetEvent(this.assetId);
  @override
  List<Object?> get props => [assetId];
}

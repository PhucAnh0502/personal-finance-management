import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pmf_app/data/models/asset_model.dart';
import 'package:equatable/equatable.dart';
import 'package:pmf_app/data/repositories/asset_repository.dart';

part 'asset_event.dart';
part 'asset_state.dart';

class AssetBloc extends Bloc<AssetEvent, AssetState> {
  final AssetRepository assetRepository;

  AssetBloc({required this.assetRepository}) : super(AssetInitial()) {
    on<FetchAssetEvent>(_onFetchAssets);
    on<AddAssetEvent>(_onAddAsset);
    on<UpdateAssetEvent>(_onUpdateAsset);
    on<DeleteAssetEvent>(_onDeleteAsset);
  }

  Future<void> _onFetchAssets(FetchAssetEvent event, emit) async {
    emit(AssetLoading());
    try {
      final assets = await assetRepository.getAssets();
      final totalValue = assets.fold(0.0, (sum, item) => sum + item.totalValue);
      emit(AssetLoaded(assets: assets, totalValue: totalValue));
    } catch (e) {
      emit(AssetError(e.toString()));
    }
  }

  Future<void> _onAddAsset(AddAssetEvent event, emit) async {
    emit(AssetLoading());
    try {
      await assetRepository.addAsset(event.asset);
      add(FetchAssetEvent());
    } catch (e) {
      emit(AssetError(e.toString()));
    }
  }

  Future<void> _onUpdateAsset(UpdateAssetEvent event, emit) async {
    emit(AssetLoading());
    try {
      await assetRepository.updateAsset(event.asset, event.assetId);
      add(FetchAssetEvent());
    } catch (e) {
      emit(AssetError(e.toString()));
    }
  }

  Future<void> _onDeleteAsset(DeleteAssetEvent event, emit) async {
    emit(AssetLoading());
    try {
      await assetRepository.deleteAsset(event.assetId);
      add(FetchAssetEvent());
    } catch (e) {
      emit(AssetError(e.toString()));
    }
  }
}

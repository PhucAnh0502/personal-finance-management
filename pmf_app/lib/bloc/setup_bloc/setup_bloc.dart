import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pmf_app/data/models/asset_model.dart';
import 'package:pmf_app/data/repositories/setup_repository.dart';

part 'setup_event.dart';
part 'setup_state.dart';

class SetupBloc extends Bloc<SetupEvent, SetupState> {
  final SetupRepository _setupRepository;

  SetupBloc({required SetupRepository setupRepository})
      : _setupRepository = setupRepository,
        super(SetupInitial()) {
    on<SetupSubmitted>((event, emit) async {
      emit(SetupLoading());
      try {
        await _setupRepository.completeSetup(
          displayName: event.displayName,
          avatarUrl: event.avatarUrl,
          accountBalance: event.accountBalance,
          assets: event.assets,
        );
        emit(SetupSuccess());
      } catch (e) {
        emit(SetupFailure(e.toString()));
      }
    });
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pmf_app/data/models/profile_model.dart';
import 'package:pmf_app/data/repositories/user_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;
  ProfileBloc({required this.userRepository}) : super(ProfileInitial()) {
    on<LoadProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await userRepository.getProfile();
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });

    on<UpdateProfile>((event, emit) async {
      try {
        await userRepository.updateBasicInfo(event.name, event.avatar);
        add(LoadProfile()); 
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}

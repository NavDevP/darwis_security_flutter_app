import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../utils/repository/hash_repository.dart';

part 'hash_event.dart';
part 'hash_state.dart';

class HashBloc extends Bloc<HashEvent, HashState> {
  final HashRepository hashRepository;
  HashBloc({required this.hashRepository}) : super(Nothing()) {
    // When User Presses the Google Login Button, we will send the GoogleSignInRequest Event to the AuthBloc to handle it and emit the Authenticated State if the user is authenticated
    on<IsolateRegisterRequested>((event, emit) async {
      emit(LoadingHash());
      try {
        SendPort port = await hashRepository.register();
        emit(IsolateRegistered(port));
      } catch (e) {
        emit(IsolateError(e.toString()));
      }
    });
    // When User Presses the SignOut Button, we will send the SignOutRequested Event to the AuthBloc to handle it and emit the UnAuthenticated State
    on<HashScanRequested>((event, emit) async {
      // emit(LoadingHash());
      try {
        var check = await hashRepository.checkHash();
        if(check){
          emit(HashScanComplete());
          return;
        }
        emit(HashListEmpty());
      } catch (e) {
        emit(HashScanError(e.toString()));
      }
    });
    // When User Presses the SignOut Button, we will send the SignOutRequested Event to the AuthBloc to handle it and emit the UnAuthenticated State
    on<ApkScanRequested>((event, emit) async {
      emit(LoadingHash());
      try {
        var check = await hashRepository.apkList();
        if(check){
          emit(ApkScanComplete());
        }else{
          emit(ApkScanError("Error"));
        }
      } catch (e) {
        emit(ApkScanError(e.toString()));
      }
    });
  }
}
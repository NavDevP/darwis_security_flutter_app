part of 'hash_bloc.dart';

abstract class HashEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// When the user signing in with google this event is called and the [AuthRepository] is called to sign in the user
class IsolateRegisterRequested extends HashEvent {}

// When the user signing out this event is called and the [AuthRepository] is called to sign out the user
class HashScanRequested extends HashEvent {}

// When the user signing out this event is called and the [AuthRepository] is called to sign out the user
class ShowAlertRequested extends HashEvent {}

// When the user signing out this event is called and the [AuthRepository] is called to sign out the user
class ApkScanRequested extends HashEvent {}
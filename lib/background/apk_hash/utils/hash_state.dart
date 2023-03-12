part of 'hash_bloc.dart';


@immutable
abstract class HashState extends Equatable {}

// When the user presses the signin or signup button the state is changed to loading first and then to Authenticated.
class Nothing extends HashState {
  @override
  List<Object?> get props => [];
}

// When the user presses the signin or signup button the state is changed to loading first and then to Authenticated.
class LoadingHash extends HashState {
  @override
  List<Object?> get props => [];
}

// When the user is authenticated the state is changed to Authenticated.
class IsolateRegistered extends HashState {
  final SendPort? port;

  IsolateRegistered(this.port);

  @override
  List<Object?> get props => [port];
}

// If any error occurs the state is changed to AuthError.
class IsolateError extends HashState {
  final String error;

  IsolateError(this.error);
  @override
  List<Object?> get props => [error];
}

// This is the initial state of the bloc. When the user is not authenticated the state is changed to Unauthenticated.
class HashScanComplete extends HashState {
  @override
  List<Object?> get props => [];
}

// If any error occurs the state is changed to AuthError.
class HashScanError extends HashState {
  final String error;

  HashScanError(this.error);
  @override
  List<Object?> get props => [error];
}

// If any error occurs the state is changed to AuthError.
class HashListEmpty extends HashState {
  @override
  List<Object?> get props => [];
}

// This is the initial state of the bloc. When the user is not authenticated the state is changed to Unauthenticated.
class ApkScanComplete extends HashState {
  @override
  List<Object?> get props => [];
}

// If any error occurs the state is changed to AuthError.
class ApkScanError extends HashState {
  final String error;

  ApkScanError(this.error);
  @override
  List<Object?> get props => [error];
}


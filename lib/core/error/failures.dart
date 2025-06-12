import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  // If the subclasses have some properties, they'll get passed to props
  const Failure();

  @override
  List<Object?> get props => [];
}

// General Failures
class ServerFailure extends Failure {}

class CacheFailure extends Failure {}

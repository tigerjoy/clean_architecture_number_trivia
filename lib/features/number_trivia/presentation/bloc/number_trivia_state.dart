part of 'number_trivia_bloc.dart';

@immutable
abstract class NumberTriviaState extends Equatable {
  const NumberTriviaState();

  @override
  List<Object> get props => [];
}

// Usually there is an initial state
// but we can skip this here

class Empty extends NumberTriviaState {}

class Loading extends NumberTriviaState {}

class Loaded extends NumberTriviaState {
  final NumberTrivia trivia;

  const Loaded(this.trivia);

  @override
  List<Object> get props => [trivia];
}

class Error extends NumberTriviaState {
  final String message;

  const Error({required this.message});

  @override
  List<Object> get props => [message];
}

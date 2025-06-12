import 'package:bloc/bloc.dart';
import 'package:clean_architecture_number_trivia/core/error/failures.dart';
import 'package:clean_architecture_number_trivia/core/usecases/usecase.dart';
import 'package:clean_architecture_number_trivia/core/util/input_converter.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const SERVER_FAILURE_MESSAGE = 'Server Failure';
const CACHE_FAILURE_MESSAGE = 'Cache Failure';
const GENERIC_FAILURE_MESSAGE = 'Unexpected Error Occurred';
const INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

typedef Trivia = Future<Either<Failure, NumberTrivia>> Function();

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required GetConcreteNumberTrivia concrete,
    required GetRandomNumberTrivia random,
    required this.inputConverter,
  }) : getConcreteNumberTrivia = concrete,
       getRandomNumberTrivia = random,
       super(Empty()) {
    on<GetTriviaForConcreteNumber>(_onGetTriviaForConcreteNumber);
    on<GetTriviaForRandomNumber>(_onGetTriviaForRandomNumber);
  }

  Future<void> _onGetTriviaForConcreteNumber(
    GetTriviaForConcreteNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {
    final inputEither = inputConverter.stringToUnsignedInteger(
      event.numberString,
    );

    await inputEither.fold(
      (failure) {
        emit(Error(message: INVALID_INPUT_FAILURE_MESSAGE));
      },
      (integer) async {
        await _getTriviaFromUseCase(
          () => getConcreteNumberTrivia(Params(number: integer)),
          emit,
        );
      },
    );
  }

  Future<void> _onGetTriviaForRandomNumber(
    GetTriviaForRandomNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {
    await _getTriviaFromUseCase(() => getRandomNumberTrivia(NoParams()), emit);
  }

  Future<void> _getTriviaFromUseCase(
    Trivia getTrivia,
    Emitter<NumberTriviaState> emit,
  ) async {
    emit(Loading());

    final triviaEither = await getTrivia();

    emit(_eitherLoadedOrErrorState(triviaEither));
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure) {
      case ServerFailure():
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure():
        return CACHE_FAILURE_MESSAGE;
      default:
        return GENERIC_FAILURE_MESSAGE;
    }
  }

  NumberTriviaState _eitherLoadedOrErrorState(
    Either<Failure, NumberTrivia> either,
  ) {
    return either.fold(
      (failure) {
        return Error(message: _mapFailureToMessage(failure));
      },
      (numberTrivia) {
        return Loaded(numberTrivia);
      },
    );
  }
}

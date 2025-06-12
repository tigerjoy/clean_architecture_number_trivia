import 'package:bloc/bloc.dart';
import 'package:clean_architecture_number_trivia/core/error/failures.dart';
import 'package:clean_architecture_number_trivia/core/util/input_converter.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetTriviaForConcreteNumber getTriviaForConcreteNumber;
  final GetTriviaForRandomNumber getTriviaForRandomNumber;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required GetTriviaForConcreteNumber concrete,
    required GetTriviaForRandomNumber random,
    required this.inputConverter,
  }) : getTriviaForConcreteNumber = concrete,
       getTriviaForRandomNumber = random,
       super(Empty()) {
    on<GetTriviaForConcreteNumber>(_onGetTriviaForConcreteNumber);
    on<GetTriviaForRandomNumber>(_onGetTriviaForRandomNumber);
  }

  Future<void> _onGetTriviaForConcreteNumber(
    GetTriviaForConcreteNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {}

  Future<void> _onGetTriviaForRandomNumber(
    GetTriviaForRandomNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {}
}

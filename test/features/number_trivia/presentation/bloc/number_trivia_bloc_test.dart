import 'package:clean_architecture_number_trivia/core/error/failures.dart';
import 'package:clean_architecture_number_trivia/core/usecases/usecase.dart';
import 'package:clean_architecture_number_trivia/core/util/input_converter.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([GetConcreteNumberTrivia, GetRandomNumberTrivia, InputConverter])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  final tNumberTrivia = NumberTrivia(text: 'Test Trivia', number: 1);
  final tNumberString = '1';
  final tNumberParsed = int.parse(tNumberString);

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
      concrete: mockGetConcreteNumberTrivia,
      random: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  void setUpMockInputConverterSuccess() => when(
    mockInputConverter.stringToUnsignedInteger(tNumberString),
  ).thenReturn(Right(tNumberParsed));

  void testEmitsInOrder(
    String description,
    List<NumberTriviaState> expected,
    Function() action,
  ) {
    test(description, () async {
      final future = expectLater(bloc.stream, emitsInOrder(expected));
      action();
      await future;
    });
  }

  test('initial state should be empty', () {
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    void setUpMockGetConcreteSuccess() => when(
      mockGetConcreteNumberTrivia(any),
    ).thenAnswer((_) async => Right(tNumberTrivia));

    test(
      'should call the InputConverter to validate and convert the string to an unsigned integer',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteSuccess();

        // act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(mockInputConverter.stringToUnsignedInteger(any));

        // assert
        verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
      },
    );

    testEmitsInOrder(
      'should emit [Error] when input is invalid',
      [Error(message: INVALID_INPUT_FAILURE_MESSAGE)],
      () {
        when(
          mockInputConverter.stringToUnsignedInteger(any),
        ).thenReturn(Left(InvalidInputFailure()));
        bloc.add(GetTriviaForConcreteNumber('invalid'));
      },
    );

    testEmitsInOrder(
      'should emit [Loading, Loaded] when data is gotten successfully',
      [Loading(), Loaded(tNumberTrivia)],
      () {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteSuccess();
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );

    testEmitsInOrder(
      'should emit [Loading, Error] on ServerFailure',
      [Loading(), Error(message: SERVER_FAILURE_MESSAGE)],
      () {
        setUpMockInputConverterSuccess();
        when(
          mockGetConcreteNumberTrivia(any),
        ).thenAnswer((_) async => Left(ServerFailure()));
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );

    testEmitsInOrder(
      'should emit [Loading, Error] on CacheFailure',
      [Loading(), Error(message: CACHE_FAILURE_MESSAGE)],
      () {
        setUpMockInputConverterSuccess();
        when(
          mockGetConcreteNumberTrivia(any),
        ).thenAnswer((_) async => Left(CacheFailure()));
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );
  });

  group('GetTriviaForRandomNumber', () {
    void setUpMockGetRandomSuccess() => when(
      mockGetRandomNumberTrivia(any),
    ).thenAnswer((_) async => Right(tNumberTrivia));

    testEmitsInOrder(
      'should emit [Loading, Loaded] when data is gotten successfully',
      [Loading(), Loaded(tNumberTrivia)],
      () {
        setUpMockGetRandomSuccess();
        bloc.add(GetTriviaForRandomNumber());
      },
    );

    testEmitsInOrder(
      'should emit [Loading, Error] on ServerFailure',
      [Loading(), Error(message: SERVER_FAILURE_MESSAGE)],
      () {
        when(
          mockGetRandomNumberTrivia(any),
        ).thenAnswer((_) async => Left(ServerFailure()));
        bloc.add(GetTriviaForRandomNumber());
      },
    );

    testEmitsInOrder(
      'should emit [Loading, Error] on CacheFailure',
      [Loading(), Error(message: CACHE_FAILURE_MESSAGE)],
      () {
        when(
          mockGetRandomNumberTrivia(any),
        ).thenAnswer((_) async => Left(CacheFailure()));
        bloc.add(GetTriviaForRandomNumber());
      },
    );
  });
}

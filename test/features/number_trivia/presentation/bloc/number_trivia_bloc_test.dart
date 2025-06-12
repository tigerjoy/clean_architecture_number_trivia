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
  late InputConverter mockInputConverter;

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

  test('initial state should be empty', () async {
    // arrange
    // act
    // assert
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    // This event takes a string
    final tNumberString = '1';
    final tInvalidNumberString = 'abc';

    // This is the successful output of the InputConverter
    final tNumberParsed = int.parse(tNumberString);

    // NumberTrivia instance is needed too
    final tNumberTrivia = NumberTrivia(text: 'Test Trivia', number: 1);

    test(
      'should call the InputConvertor to validate and convert the string to an unsigned integer',
      () async {
        // arrange
        when(
          mockInputConverter.stringToUnsignedInteger(tNumberString),
        ).thenReturn(Right(tNumberParsed));

        // act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(
          mockInputConverter.stringToUnsignedInteger(tNumberString),
        );

        // assert
        verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
      },
    );

    test('should emit [Error] state when the input is invalid', () async {
      // arrange
      when(
        mockInputConverter.stringToUnsignedInteger(tInvalidNumberString),
      ).thenReturn(Left(InvalidInputFailure()));

      // assert later
      final expected = [Empty(), Error(message: INVALID_INPUT_FAILURE_MESSAGE)];
    });
  });
}

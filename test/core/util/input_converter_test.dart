import 'package:clean_architecture_number_trivia/core/util/input_converter.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInt', () {
    test(
      'should return a integer when a string represents an unsigned integer',
      () async {
        // arrange
        final tUnsignedNumberString = "123";

        // act
        final result = inputConverter.stringToUnsignedInteger(
          tUnsignedNumberString,
        );

        // assert
        expect(result, equals(Right(123)));
      },
    );

    test(
      'should return a InvalidInputFailure when a string represents an negative integer',
      () async {
        // arrange
        final tNegativeNumberString = "-123";

        // act
        final result = inputConverter.stringToUnsignedInteger(
          tNegativeNumberString,
        );

        // assert
        expect(result, equals(Left(InvalidInputFailure())));
      },
    );

    test(
      'should return a InvalidInputFailure when a string represents a non-integer value',
      () async {
        // arrange
        final tInvalidNumberString = "abc";

        // act
        final result = inputConverter.stringToUnsignedInteger(
          tInvalidNumberString,
        );

        // assert
        expect(result, equals(Left(InvalidInputFailure())));
      },
    );
  });
}

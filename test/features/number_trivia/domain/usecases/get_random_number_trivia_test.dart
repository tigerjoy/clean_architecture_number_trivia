import 'package:clean_architecture_number_trivia/core/usecases/usecase.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_random_number_trivia_test.mocks.dart';

@GenerateMocks([NumberTriviaRepository])
void main() {
  late GetRandomNumberTrivia usecase;
  late MockNumberTriviaRepository mockNumberTriviaRepository;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetRandomNumberTrivia(mockNumberTriviaRepository);
  });

  final tNumberTrivia = NumberTrivia(number: 1, text: 'test');

  test('should get trivia from repository', () async {
    // arrange
    when(
      mockNumberTriviaRepository.getRandomNumberTrivia(),
    ).thenAnswer((_) async => Right(tNumberTrivia));

    // act
    // Since random number doesn't require any params
    final result = await usecase(NoParams());

    // assert
    expect(result, Right(tNumberTrivia));
    verify(mockNumberTriviaRepository.getRandomNumberTrivia());
    verifyNoMoreInteractions(mockNumberTriviaRepository);
  });
}

import 'package:clean_architecture_number_trivia/core/error/failures.dart';
import 'package:clean_architecture_number_trivia/core/usecases/usecase.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:dartz/dartz.dart';

class GetRandomNumberTrivia extends UseCase<NumberTrivia, NoParams> {
  final NumberTriviaRepository repository;

  GetRandomNumberTrivia(this.repository);

  @override
  Future<Either<Failure, NumberTrivia>> call(NoParams params) {
    return repository.getRandomNumberTrivia();
  }
}

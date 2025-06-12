import 'package:clean_architecture_number_trivia/core/error/exception.dart';
import 'package:clean_architecture_number_trivia/core/error/failures.dart';
import 'package:clean_architecture_number_trivia/core/network/network_info.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';

import '../../domain/repositories/number_trivia_repository.dart';

typedef _ConcreteOrRandomChooser = Future<NumberTriviaModel> Function();

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaRemoteDataSource remoteDataSource;
  final NumberTriviaLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  NumberTriviaRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
    int number,
  ) async {
    return await _getTrivia(() {
      return remoteDataSource.getConcreteNumberTrivia(number);
    });
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    return await _getTrivia(() {
      return remoteDataSource.getRandomNumberTrivia();
    });
  }

  Future<Either<Failure, NumberTrivia>> _getTrivia(
    _ConcreteOrRandomChooser getConcreteOrRandom,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteTrivia = await getConcreteOrRandom();
        localDataSource.cacheNumberTrivia(remoteTrivia);
        return Right(remoteTrivia);
      }

      return Right(await localDataSource.getLastNumberTrivia());
    } on ServerException {
      return Left(ServerFailure());
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}

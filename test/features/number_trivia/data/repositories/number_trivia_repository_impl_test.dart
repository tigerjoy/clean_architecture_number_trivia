import 'package:clean_architecture_number_trivia/core/error/exception.dart';
import 'package:clean_architecture_number_trivia/core/error/failures.dart';
import 'package:clean_architecture_number_trivia/core/network/network_info.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_repository_impl_test.mocks.dart';

@GenerateMocks([
  NumberTriviaRemoteDataSource,
  NumberTriviaLocalDataSource,
  NetworkInfo,
])
void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockNumberTriviaRemoteDataSource mockRemoteDataSource;
  late MockNumberTriviaLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockNumberTriviaRemoteDataSource();
    mockLocalDataSource = MockNumberTriviaLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    // DATAFOR THE MOCKS AND ASSERTIONS
    // We'll use these three variables throughout
    // all the tests
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel(number: tNumber, text: 'test');
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('should check if device is online', () {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        mockRemoteDataSource.getConcreteNumberTrivia(any),
      ).thenAnswer((_) async => tNumberTriviaModel);

      // act
      repository.getConcreteNumberTrivia(tNumber);

      // assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test(
        'should return remote data when the call to remote data source is successful',
        () async {
          // arrange
          when(
            mockRemoteDataSource.getConcreteNumberTrivia(tNumber),
          ).thenAnswer((_) async => tNumberTriviaModel);

          // act
          final result = await repository.getConcreteNumberTrivia(tNumber);

          // assert
          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should cache the data locally when the call to the remote data source is successful',
        () async {
          // arrange
          when(
            mockRemoteDataSource.getConcreteNumberTrivia(tNumber),
          ).thenAnswer((_) async => tNumberTriviaModel);

          // act
          await repository.getConcreteNumberTrivia(tNumber);

          // assert
          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return server failure when the call to the remote data source is unsuccessful',
        () async {
          // arrange
          when(
            mockRemoteDataSource.getConcreteNumberTrivia(tNumber),
          ).thenThrow(ServerException(message: "404 Not Found"));

          // act
          final result = await repository.getConcreteNumberTrivia(tNumber);

          // assert
          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
        () async {
          // arrange
          when(
            mockLocalDataSource.getLastNumberTrivia(),
          ).thenAnswer((_) async => tNumberTriviaModel);

          // act
          final result = await repository.getConcreteNumberTrivia(tNumber);

          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should return cache failure when there is no cached data present',
        () async {
          // arrange
          when(
            mockLocalDataSource.getLastNumberTrivia(),
          ).thenThrow(CacheException(message: 'Cache is empty'));

          // act
          final result = await repository.getConcreteNumberTrivia(tNumber);

          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });

  group('getRandomNumberTrivia', () {
    // DATAFOR THE MOCKS AND ASSERTIONS
    // We'll use these three variables throughout
    // all the tests
    final tNumber = 123;
    final tNumberTriviaModel = NumberTriviaModel(
      number: tNumber,
      text: 'test text',
    );
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('should check if device is online', () {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        mockRemoteDataSource.getRandomNumberTrivia(),
      ).thenAnswer((_) async => tNumberTriviaModel);

      // act
      repository.getRandomNumberTrivia();

      // assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test(
        'should return remote data when the call to remote data source is successful',
        () async {
          // arrange
          when(
            mockRemoteDataSource.getRandomNumberTrivia(),
          ).thenAnswer((_) async => tNumberTriviaModel);

          // act
          final result = await repository.getRandomNumberTrivia();

          // assert
          verify(mockRemoteDataSource.getRandomNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should cache the data locally when the call to the remote data source is successful',
        () async {
          // arrange
          when(
            mockRemoteDataSource.getRandomNumberTrivia(),
          ).thenAnswer((_) async => tNumberTriviaModel);

          // act
          await repository.getRandomNumberTrivia();

          // assert
          verify(mockRemoteDataSource.getRandomNumberTrivia());
          verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return server failure when the call to the remote data source is unsuccessful',
        () async {
          // arrange
          when(
            mockRemoteDataSource.getRandomNumberTrivia(),
          ).thenThrow(ServerException(message: "404 Not Found"));

          // act
          final result = await repository.getRandomNumberTrivia();

          // assert
          verify(mockRemoteDataSource.getRandomNumberTrivia());
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
        () async {
          // arrange
          when(
            mockLocalDataSource.getLastNumberTrivia(),
          ).thenAnswer((_) async => tNumberTriviaModel);

          // act
          final result = await repository.getRandomNumberTrivia();

          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should return cache failure when there is no cached data present',
        () async {
          // arrange
          when(
            mockLocalDataSource.getLastNumberTrivia(),
          ).thenThrow(CacheException(message: 'Cache is empty'));

          // act
          final result = await repository.getRandomNumberTrivia();

          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });
}

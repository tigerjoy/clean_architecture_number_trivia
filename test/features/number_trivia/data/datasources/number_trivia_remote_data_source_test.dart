import 'dart:convert';
import 'package:clean_architecture_number_trivia/core/error/exception.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_remote_data_source_test.mocks.dart';

@GenerateMocks([], customMocks: [MockSpec<http.Client>(as: #MockHttpClient)])
void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;

  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(
      mockHttpClient.get(any, headers: anyNamed('headers')),
    ).thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure404() {
    when(
      mockHttpClient.get(any, headers: anyNamed('headers')),
    ).thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
      json.decode(fixture('trivia.json')),
    );

    test(
      'should perform a GET request on a URL with number being the end-point and with application/json header',
      () async {
        // arrange
        setUpMockHttpClientSuccess200();

        // act
        dataSource.getConcreteNumberTrivia(tNumber);

        // assert
        verify(
          mockHttpClient.get(
            Uri.parse('$CONCRETE_TRIVIA_BASE_URL/$tNumber'),
            headers: {'Content-Type': 'application/json'},
          ),
        );
      },
    );

    test(
      'should return NumberTrivia when the response code is 200 (success)',
      () async {
        // arrange
        setUpMockHttpClientSuccess200();

        // act
        final result = await dataSource.getConcreteNumberTrivia(tNumber);

        // assert
        verify(
          mockHttpClient.get(
            Uri.parse('$CONCRETE_TRIVIA_BASE_URL/$tNumber'),
            headers: {'Content-Type': 'application/json'},
          ),
        );
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response is code is 404 or other',
      () async {
        // arrange
        setUpMockHttpClientFailure404();

        // act
        final call = dataSource.getConcreteNumberTrivia;

        // assert
        expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
      },
    );

    group('getRandomNumberTrivia', () {
      final tNumberTriviaModel = NumberTriviaModel.fromJson(
        json.decode(fixture('trivia.json')),
      );

      test(
        'should perform a GET request on a URL with *random endpoint with application/json header',
        () async {
          // arrange
          setUpMockHttpClientSuccess200();

          // act
          await dataSource.getRandomNumberTrivia();

          // assert
          verify(
            mockHttpClient.get(
              Uri.parse(RANDOM_TRIVIA_BASE_URL),
              headers: {'Content-Type': 'application/json'},
            ),
          );
        },
      );

      test(
        'should return NumberTrivia when the return code is 200 (success)',
        () async {
          // arrange
          setUpMockHttpClientSuccess200();

          // act
          final result = await dataSource.getRandomNumberTrivia();

          // assert
          expect(result, equals(tNumberTriviaModel));
        },
      );

      test(
        'should throw ServerException when the response code is 404 or other',
        () async {
          // arrange
          setUpMockHttpClientFailure404();

          // act
          final call = dataSource.getRandomNumberTrivia;

          // assert
          expect(() => call(), throwsA(TypeMatcher<ServerException>()));
        },
      );
    });
  });
}

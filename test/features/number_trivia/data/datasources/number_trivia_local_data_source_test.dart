import 'dart:convert';

import 'package:clean_architecture_number_trivia/core/error/exception.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_local_data_source_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
      jsonDecode(fixture('trivia_cached.json')),
    );

    test('should return NumberTrivia from Shared Preferences', () async {
      // arrange
      when(
        mockSharedPreferences.getString(any),
      ).thenReturn(fixture('trivia_cached.json'));

      // act
      final result = await dataSource.getLastNumberTrivia();

      // assert
      verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA_LOCAL_KEY));
      expect(result, equals(tNumberTriviaModel));
    });

    test('should return CacheException when local cache is empty', () async {
      // arrange
      when(mockSharedPreferences.getString(any)).thenReturn(null);

      // act
      // Not calling the method here, just storing it
      final call = dataSource.getLastNumberTrivia;

      // assert
      // Calling the method happens from a higher-order function
      // This is needed to test if the method throws an exception
      expect(() => call(), throwsA(TypeMatcher<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test Text');

    test('should call SharedPreferences to cache the data', () async {
      // arrange
      when(
        mockSharedPreferences.setString(any, any),
      ).thenAnswer((_) => Future.value(true));

      // act
      await dataSource.cacheNumberTrivia(tNumberTriviaModel);

      // assert
      final expectedJsonString = json.encode(tNumberTriviaModel);
      verify(
        mockSharedPreferences.setString(
          CACHED_NUMBER_TRIVIA_LOCAL_KEY,
          expectedJsonString,
        ),
      );
    });
  });
}

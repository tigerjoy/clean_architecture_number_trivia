import 'dart:convert';

import 'package:clean_architecture_number_trivia/core/error/exception.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class NumberTriviaLocalDataSource {
  /// Gets the cached [NumberTriviaModel] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws [NoLocalDataException] if no cached data is present.
  Future<NumberTriviaModel> getLastNumberTrivia();

  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache);
}

const CACHED_NUMBER_TRIVIA_LOCAL_KEY = 'CACHED_NUMBER_TRIVIA';

class NumberTriviaLocalDataSourceImpl extends NumberTriviaLocalDataSource {
  final SharedPreferences sharedPreferences;

  NumberTriviaLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<NumberTriviaModel> getLastNumberTrivia() {
    final cachedNumberTriviaJson = sharedPreferences.getString(
      CACHED_NUMBER_TRIVIA_LOCAL_KEY,
    );

    if (cachedNumberTriviaJson == null) {
      throw CacheException(message: 'Cache is empty');
    }

    return Future.value(
      NumberTriviaModel.fromJson(json.decode(cachedNumberTriviaJson)),
    );
  }

  @override
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache) {
    return sharedPreferences.setString(
      CACHED_NUMBER_TRIVIA_LOCAL_KEY,
      json.encode(triviaToCache.toJson()),
    );
  }
}

import 'dart:convert';

import 'package:clean_architecture_number_trivia/core/error/exception.dart';
import 'package:flutter/foundation.dart';

import '../models/number_trivia_model.dart';
import 'package:http/http.dart' as http;

typedef HttpClient = http.Client;

abstract class NumberTriviaRemoteDataSource {
  /// Calls the http://numbersapi.com/{number} endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);

  // Calls the http://numbersapi.com/random endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

const CONCRETE_TRIVIA_BASE_URL = 'http://numbersapi.com';
const RANDOM_TRIVIA_BASE_URL = 'http://numbersapi.com/random';

class NumberTriviaRemoteDataSourceImpl extends NumberTriviaRemoteDataSource {
  final HttpClient client;

  NumberTriviaRemoteDataSourceImpl({required this.client});

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) async =>
      _getTriviaFromURL('$CONCRETE_TRIVIA_BASE_URL/$number');

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() async =>
      _getTriviaFromURL(RANDOM_TRIVIA_BASE_URL);

  Future<NumberTriviaModel> _getTriviaFromURL(String url) async {
    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw ServerException(message: response.body);
      }

      final numberTriviaJson = json.decode(response.body);

      return NumberTriviaModel.fromJson(numberTriviaJson);
    } on ServerException {
      rethrow;
    } on Exception catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

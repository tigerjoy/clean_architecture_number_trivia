class ServerException implements Exception {
  String message;

  ServerException({required this.message});
}

class CacheException implements Exception {
  String message;

  CacheException({required this.message});
}

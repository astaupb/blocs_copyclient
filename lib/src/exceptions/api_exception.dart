class ApiException implements Exception {
  String info;
  int statusCode;

  ApiException(this.statusCode, {this.info});

  @override
  String toString() => '$info ($statusCode)';
}

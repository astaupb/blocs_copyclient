import 'dart:async';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

class ApiRequest extends Request {
  final String method;
  final String path;
  final Backend backend;
  final Map<String, String> queryParameters;

  ApiRequest(this.method, this.path, this.backend, {this.queryParameters})
      : super(method, Uri.https(backend.host, backend.basePath + path, queryParameters));

  Map<String, dynamic> toMap() => {
        'method': method,
        'path': path,
        'query': queryParameters,
        'backend': backend.toMap(),
      };

  @override
  String toString() => toMap().toString();
}

abstract class Backend {
  final String host;
  final String basePath;
  final Client _innerClient;

  Backend(this._innerClient, {@required this.host, @required this.basePath});

  void close() {
    _innerClient.close();
  }

  Future<StreamedResponse> send(BaseRequest request);

  Map toMap();

  String toStringDeep();
}

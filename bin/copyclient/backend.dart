import 'dart:async';

import 'package:blocs_copyclient/src/models/backend.dart';
import 'package:http/http.dart';

class BackendShiva implements Backend {
  final String host = 'astaprint.upb.de';
  final String basePath = '/api/v1';
  final Client _innerClient;

  BackendShiva(this._innerClient) {}

  @override
  void close() {
    _innerClient.close();
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    Request modRequest = Request(request.method, request.url);

    modRequest.persistentConnection = true;

    /// copy over headers from [request]
    for (String key in request.headers.keys) {
      modRequest.headers[key] = request.headers[key];
    }

    modRequest.headers['Connection'] = 'keep-alive';

    /// copy over body from [request]
    if (request is Request) {
      modRequest.bodyBytes = request.bodyBytes;
    }

    /// send finalized request through [_innerClient] and return [StreamedResponse]
    return _innerClient.send(modRequest);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map();
    map['host'] = host;
    map['basePath'] = basePath;
    return map;
  }

  @override
  String toStringDeep() => toMap().toString();
}

class BackendSunrise implements Backend {
  final String host = 'sunrise.upb.de';
  final String basePath = '/astaprint';
  final Client _innerClient;

  BackendSunrise(this._innerClient) {}

  @override
  void close() {
    _innerClient.close();
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    Request modRequest = Request(request.method, request.url);

    modRequest.persistentConnection = true;

    /// copy over headers from [request]
    for (String key in request.headers.keys) {
      modRequest.headers[key] = request.headers[key];
    }

    modRequest.headers['Connection'] = 'keep-alive';

    /// copy over body from [request]
    if (request is Request) {
      modRequest.bodyBytes = request.bodyBytes;
    }

    /// send finalized request through [_innerClient] and return [StreamedResponse]
    return _innerClient.send(modRequest);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map();
    map['host'] = host;
    map['basePath'] = basePath;
    return map;
  }

  @override
  String toStringDeep() => toMap().toString();
}

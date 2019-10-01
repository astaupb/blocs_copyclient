import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

import 'upload_events.dart';
import 'upload_state.dart';
import '../../exceptions.dart';
import '../models/backend.dart';
import '../models/dispatcher_task.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final Logger log = Logger('UploadBloc');

  Backend _backend;
  String _token;

  int _activeUploads = 0;

  List<DispatcherTask> _queue = List<DispatcherTask>();

  UploadBloc(this._backend) {
    log.fine('$this started');
  }

  @override
  get initialState => UploadState.init();

  onStart(String token) => dispatch(InitUploads(token));

  onRefresh() => dispatch(RefreshUploads());

  onUpload(
    List<int> data, {
    String filename,
    String password
    bool a3,
    bool color,
    int duplex,
  }) =>
      dispatch(UploadFile(
        data: data,
        filename: filename,
        password: password,
        a3: a3??,
        color: color??,
        duplex: duplex??,
      ));

  @override
  Stream<UploadState> mapEventToState(UploadEvent event) async* {
    log.fine('Event: $event');

    if (event is InitUploads) _token = event.token;

    if (event is InitUploads || event is RefreshUploads) {
      try {
        await _getQueue();
        yield UploadState.result(_queue);
      } on ApiException catch (e) {
        yield UploadState.exception(e);
      }
    }
    if (event is UploadFile) {
      _activeUploads++;
      int localId = _activeUploads;
      _queue.add(DispatcherTask(
        filename: event.filename,
        isUploading: true,
        localId: localId,
      ));
      yield UploadState.result(_queue);

      try {
        await _postQueue(
          event.data,
          filename: event.filename,
          password: event.password,
          a3: event.a3,
          color: event.color,
          duplex: event.duplex,
        ).then((String uid) {
          _queue.forEach((task) {
            if (task.localId == localId) {
              task.uid = uid;
              task.isUploading = false;
            }
          });
        });
        yield UploadState.result(_queue);
      } on ApiException catch (e) {
        yield UploadState.exception(e);
      }
    }
  }

  @override
  void onTransition(Transition<UploadEvent, UploadState> transition) {
    log.fine('State: ${transition.nextState}');
    super.onTransition(transition);
  }

  @override
  void dispose() {
    log.fine('disposing of $this');
    super.dispose();
  }

  Future<String> _postQueue(
    List<int> data, {
    String filename = '',
    String password = '',
    bool a3,
    bool color,
    int duplex,
  }) async {
    Map<String, dynamic> queryParameters = {
      'filename': filename,
      //'password': password
    };

    a3 != null ? queryParameters.putIfAbsent('a3', a3);
    color != null ? queryParameters.putIfAbsent('color', color);
    duplex != null ? queryParameters.putIfAbsent('duplex', duplex);

    Request request = ApiRequest(
      'POST',
      '/jobs/queue',
      _backend,
      queryParameters: queryParameters,
    );
    request.headers['Content-Type'] = 'application/pdf';
    request.headers['X-Api-Key'] = _token;
    request.bodyBytes = data;

    log.finer('[_postQueue] request: $request');

    return await _backend.send(request).then(
      (response) async {
        String body = utf8.decode(await response.stream.toBytes());
        log.finest('[_postQueue] response: ${response.statusCode} $body');
        if (response.statusCode == 202) {
          return json.decode(body);
        } else {
          throw ApiException(response.statusCode, info: 'status code other than 202 received');
        }
      },
    );
  }

  Future<void> _getQueue() async {
    Request request = ApiRequest('GET', '/jobs/queue', _backend);
    request.headers['Accept'] = 'application/json';
    request.headers['X-Api-Key'] = _token;

    log.finer('[_getQueue] request: $request');

    return await request.send().then(
      (response) async {
        if (response.statusCode == 200) {
          final String body = utf8.decode(await response.stream.toBytes());
          log.finest('[_getQueue] response: ${response.statusCode} $body');
          _queue = List<DispatcherTask>.from(
              json.decode(body).map((task) => DispatcherTask.fromMap(task)));
        } else {
          throw ApiException(response.statusCode, info: 'status code other than 200 received');
        }
      },
    );
  }
}

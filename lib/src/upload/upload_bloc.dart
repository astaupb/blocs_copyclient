import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

import '../../exceptions.dart';
import '../models/backend.dart';
import '../models/dispatcher_task.dart';
import 'upload_events.dart';
import 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final Logger log = Logger('UploadBloc');

  Backend _backend;
  String _token;

  int _activeUploads = 0;

  List<DispatcherTask> _queue = <DispatcherTask>[];

  UploadBloc(this._backend) : super(UploadState.init()) {
    log.fine('$this started');
  }

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
    } else if (event is UploadFile) {
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
          copies: event.copies,
          preprocess: event.preprocess,
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
    } else if (event is AddUpload) {
      _activeUploads++;
      int localId = _activeUploads;
      _queue.add(DispatcherTask(
          filename: event.filename, isUploading: true, localId: localId, progress: event.progress));
      yield UploadState.result(_queue);
    } else if (event is UpdateProgress) {
      _queue.singleWhere((DispatcherTask task) => task.localId == event.localId).progress =
          event.progress;
      yield UploadState.result(_queue);
    }
  }

  void onAddUpload(String filename, UploadProgress progress) =>
      this.add(AddUpload(filename, progress));

  void onRefresh() => this.add(RefreshUploads());

  void onStart(String token) => this.add(InitUploads(token));

  @override
  void onTransition(Transition<UploadEvent, UploadState> transition) {
    log.fine('State: ${transition.nextState}');
    super.onTransition(transition);
  }

  void onUpdateProgress(int localId, UploadProgress progress) =>
      this.add(UpdateProgress(localId, progress));

  void onUpload(
    List<int> data, {
    String filename,
    String password,
    bool a3,
    bool color,
    int duplex,
    int copies,
    int preprocess,
  }) =>
      this.add(UploadFile(
        data: data,
        filename: filename,
        password: password,
        a3: a3,
        color: color,
        duplex: duplex,
        copies: copies,
        preprocess: preprocess,
      ));

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

  Future<String> _postQueue(
    List<int> data, {
    String filename,
    String password = '',
    bool a3,
    bool color,
    int duplex,
    int copies,
    int preprocess,
  }) async {
    Request request = ApiRequest(
      'POST',
      '/jobs/queue',
      _backend,
      queryParameters: {
        if (filename != null) 'filename': filename,
        //'password': password,
        if (a3 != null) 'a3': a3.toString(),
        if (color != null) 'color': color.toString(),
        if (duplex != null) 'duplex': duplex.toString(),
        if (copies != null) 'copies': copies.toString(),
        if (preprocess != null) 'preprocess': preprocess.toString(),
      },
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
}

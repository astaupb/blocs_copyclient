import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

import '../../exceptions.dart';
import '../models/backend.dart';
import '../models/print_queue_result.dart';
import '../models/print_queue_task.dart';
import 'print_queue_events.dart';
import 'print_queue_state.dart';

class PrintQueueBloc extends Bloc<PrintQueueEvent, PrintQueueState> {
  final log = Logger('PrintQueueBloc');

  Backend _backend;
  String _token;

  int _deviceId;
  List<PrintQueueTask> _incoming;
  List<PrintQueueTask> _processing;

  PrintQueueBloc(this._backend) {
    log.fine('$this started');
  }

  @override
  get initialState => PrintQueueState.init();

  @override
  dispose() {
    log.fine('disposing of $this');
    super.dispose();
  }

  @override
  Stream<PrintQueueState> mapEventToState(
      PrintQueueState state, PrintQueueEvent event) async* {
    log.fine('Event: $event');

    if (event is InitPrintQueue) {
      _token = event.token;
    }
    if (event is SetDeviceId) {
      _deviceId = event.deviceId;
    }
    if (event is GetQueue) {
      if (event.deviceId != null) {
        _deviceId = event.deviceId;
      }
    }

    if (event is GetQueue) {
      try {
        await _getQueue();
        yield PrintQueueState.result(PrintQueueResult(_incoming, _processing));
      } on ApiException catch (e) {
        yield PrintQueueState.exception(e);
      }
    }

    if (event is AppendJob) {
      try {
        await _postQueue(jobId: event.jobId);
        yield PrintQueueState.result(PrintQueueResult(_incoming, _processing));
      } on ApiException catch (e) {
        yield PrintQueueState.exception(e);
      }
    }

    if (event is LockQueue) {
      try {
        String lockUid = await _postQueue(jobId: int.tryParse(event.queueUid));
        yield PrintQueueState.locked(lockUid);
      } on ApiException catch (e) {
        yield PrintQueueState.exception(e);
      }
    }

    if (event is CancelJob) {
      try {
        await _deleteQueue(event.uid);
        yield PrintQueueState.result(PrintQueueResult(_incoming, _processing));
      } on ApiException catch (e) {
        yield PrintQueueState.exception(e);
      }
    }
  }

  onLockDevice({String queueUid}) => dispatch(LockQueue(queueUid: queueUid));

  onRefresh({int deviceId}) => dispatch(GetQueue(deviceId ?? _deviceId));

  onStart(String token) => dispatch(InitPrintQueue(token));

  @override
  onTransition(Transition<PrintQueueEvent, PrintQueueState> transition) {
    log.fine('State: ${transition.nextState}');

    super.onTransition(transition);
  }

  setDeviceId(int deviceId) => dispatch(SetDeviceId(deviceId));

  Future<void> _deleteQueue(String uid) async {
    Request request =
        new ApiRequest('POST', '/printers/$_deviceId/queue/$uid', _backend);
    request.headers['X-Api-Key'] = _token;

    log.finer('_deleteQueue $request');

    return await _backend.send(request).then((response) async {
      log.finer('_deleteQueue: ${response.statusCode}');
      if (response.statusCode == 205) {
        return;
      } else {
        throw ApiException(response.statusCode, info: 'not 205');
      }
    });
  }

  Future<void> _getQueue() async {
    Request request =
        new ApiRequest('GET', '/printers/$_deviceId/queue', _backend);
    request.headers['X-Api-Key'] = _token;
    request.headers['Accept'] = 'application/json';

    log.finer('_getQueue $request');
    return await _backend.send(request).then((response) async {
      log.finer('_getQueue: ${response.statusCode}');
      if (response.statusCode == 200) {
        var body = json.decode(utf8.decode(await response.stream.toBytes()));
        _incoming = List.from(
            body['incoming'].map((value) => PrintQueueTask.fromMap(value)));
        _processing = List.from(
            body['processing'].map((value) => PrintQueueTask.fromMap(value)));
        return;
      } else {
        throw ApiException(response.statusCode, info: 'not 200');
      }
    });
  }

  Future<String> _postQueue({int jobId}) async {
    String path = '/printers/$_deviceId/queue';
    if (jobId != null) {
      path += '?id=$jobId';
    }
    Request request = new ApiRequest('POST', path, _backend);
    request.headers['X-Api-Key'] = _token;

    log.finer('_postQueue $request');

    return await _backend.send(request).then((response) async {
      log.finer('_postQueue: ${response.statusCode}');
      if (response.statusCode == 202) {
        return await response.stream.bytesToString();
      } else {
        throw ApiException(response.statusCode, info: 'not 202');
      }
    });
  }
}

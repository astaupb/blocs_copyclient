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
  Stream<PrintQueueState> mapEventToState(PrintQueueEvent event) async* {
    log.fine('Event: $event');

    if (event is InitPrintQueue) {
      _token = event.token;
    }
    if (event is SetDeviceId) {
      _deviceId = event.deviceId;
    }

    if (event is AppendJob) {
      try {
        await _postQueue(jobId: event.jobId);
        yield PrintQueueState.result(PrintQueueResult(_incoming, _processing));
      } on ApiException catch (e) {
        yield PrintQueueState.exception(e);
      }
    } else if (event is LockQueue) {
      try {
        String lockUid = '';
        if (event.queueUid != null) {
          lockUid = await _postQueue();
        } else {
          lockUid = await _postQueue();
        }
        yield PrintQueueState.locked(lockUid);
      } on ApiException catch (e) {
        yield PrintQueueState.exception(e);
      }
    } else if (event is CancelJob) {
      try {
        await _deleteQueue();
        yield PrintQueueState.result(PrintQueueResult(_incoming, _processing));
      } on ApiException catch (e) {
        yield PrintQueueState.exception(e);
      }
    }
  }

  onDelete() => this.add(CancelJob());

  onLockDevice({String queueUid}) => this.add(LockQueue(queueUid: queueUid ?? null));

  onSetDeviceId(int deviceId) => this.add(SetDeviceId(deviceId));

  onStart(String token) => this.add(InitPrintQueue(token));

  @override
  onTransition(Transition<PrintQueueEvent, PrintQueueState> transition) {
    log.fine('State: ${transition.nextState}');

    super.onTransition(transition);
  }

  Future<void> _deleteQueue() async {
    Request request = ApiRequest('DELETE', '/printers/$_deviceId/queue', _backend);
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

  Future<String> _postQueue({int jobId}) async {
    Request request = ApiRequest(
      'POST',
      '/printers/$_deviceId/queue',
      _backend,
      queryParameters: (jobId != null) ? {'id': jobId.toString()} : null,
    );
    request.headers['X-Api-Key'] = _token;

    log.finer('_postQueue $request');

    return await _backend.send(request).then((response) async {
      String stringResponse = await response.stream.bytesToString();
      log.finer('_postQueue: ${response.statusCode} $stringResponse');
      if (response.statusCode == 202) {
        return json.decode(stringResponse);
      } else {
        throw ApiException(response.statusCode, info: 'not 202');
      }
    });
  }
}

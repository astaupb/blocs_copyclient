import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:quiver/cache.dart';

import '../models/backend.dart';
import '../models/job.dart';
import '../exceptions.dart';
import 'joblist_events.dart';
import 'joblist_state.dart';

class JoblistBloc extends Bloc<JoblistEvent, JoblistState> {
  final log = Logger('JoblistBloc');

  Backend _backend;
  String _token;
  Cache cache;

  List<Job> _jobs;

  JoblistBloc(this._backend, this._token, {this.cache}) {
    log.fine('$this started');
  }

  @override
  JoblistState get initialState => JoblistState.init();

  get jobs => _jobs;

  @override
  void dispose() {
    log.fine('disposing of $this');
    super.dispose();
  }

  int getIndexByUid(String uid) => _jobs.indexWhere((job) => job.uid == uid);

  @override
  Stream<JoblistState> mapEventToState(JoblistState state, JoblistEvent event) async* {
    log.fine('Event: ${event}');

    /// go into busy state to show busyness
    yield JoblistState.busy();

    if (event is InitJobs) {
      try {
        await _getJobs();
        yield JoblistState.result(_jobs);
      } on ApiException catch (e) {
        yield JoblistState.exception(e);
      }
    } else if (event is RefreshJobs) {
      try {
        await _getJobs();
        yield JoblistState.result(_jobs);
      } on ApiException catch (e) {
        yield JoblistState.exception(e);
      }
    } else if (event is PrintJob) {
      try {
        await _printJob(event.deviceId,
            ((event.uid != null) ? event.uid : _jobs[event.index].uid));
        int index = getIndexByUid(event.uid);
        if (!_jobs[index].jobOptions.keep) {
          _jobs.remove(index);
        }
        yield JoblistState.result(_jobs);
      } on ApiException catch (e) {
        yield JoblistState.exception(e);
      }
    } else if (event is DeleteJob) {
      try {
        await _deleteJob(
            ((event.uid != null) ? event.uid : _jobs[event.index].uid));
        yield JoblistState.result(_jobs);
      } on ApiException catch (e) {
        yield JoblistState.exception(e);
      }
    }
  }

  onDelete(int index) => dispatch(DeleteJob(index: index));

  onDeleteByUid(String uid) => dispatch(DeleteJob(uid: uid));

  onPrint(String deviceId, int index) => dispatch(PrintJob(
        deviceId: deviceId,
        index: index,
      ));

  onPrintbyUid(String deviceId, String uid) => dispatch(PrintJob(
        deviceId: deviceId,
        uid: uid,
      ));

  onRefresh() => dispatch(RefreshJobs());

  onStart() => dispatch(InitJobs());

  @override
  void onTransition(Transition<JoblistEvent, JoblistState> transition) {
    log.fine('State: ${transition.nextState}');
    if (transition.nextState.isResult) {
      try {
        (cache ?? null).set('jobs', _jobs);
      } catch (e) {
        log.severe(
            'you should use caching with this BloC, pass it in the constructor');
      }
    }

    super.onTransition(transition);
  }

  onUpdateJob() => null;

  Future<void> _deleteJob(String uid) async {
    Request request = ApiRequest('DELETE', '/jobs/$uid', _backend);
    request.headers['X-Api-Key'] = _token;

    log.finer('_deleteJob: $request');

    return await _backend.send(request).then(
      (response) async {
        log.finer('_deleteJob: ${response.statusCode}');
        if (response.statusCode == 205) {
          _jobs.removeWhere((Job job) => job.uid == uid);
        } else {
          throw ApiException(response.statusCode,
              info: 'received status code other than 205');
        }
      },
    );
  }

  /// request job list from backend route and update local list instance
  Future<void> _getJobs() async {
    Request request = ApiRequest('GET', '/jobs', _backend);
    request.headers['Accept'] = 'application/json';
    request.headers['X-Api-Key'] = _token;

    log.finer('_getJobs: $request');

    return await _backend.send(request).then(
      (response) async {
        log.finer('_getJobs: ${response.statusCode}');
        if (response.statusCode == 200) {
          _jobs = List.from(json
              .decode(utf8.decode(await response.stream.toBytes()))
              .map((value) => Job.fromMap(value)));
        } else {
          throw ApiException(response.statusCode,
              info: 'status code other than 200 received');
        }
      },
    );
  }

  Future<void> _printJob(String deviceId, String uid) async {
    Request request = ApiRequest(
      'POST',
      '/printers/$deviceId/queue',
      _backend,
      queryParameters: {'uid': uid},
    );
    request.headers['X-Api-Key'] = _token;

    log.finer('_printJob: $request');

    return await _backend.send(request).then(
      (response) async {
        log.finer('_printJob: ${response.statusCode}');
        if (response.statusCode == 202) {
        } else {
          throw ApiException(response.statusCode,
              info: 'status code other than 202 received');
        }
      },
    );
  }
}

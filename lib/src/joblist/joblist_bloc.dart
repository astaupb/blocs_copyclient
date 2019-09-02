import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:quiver/cache.dart';

import '../../exceptions.dart';
import '../models/backend.dart';
import '../models/job.dart';
import '../models/joboptions.dart';
import 'joblist_events.dart';
import 'joblist_state.dart';

class JoblistBloc extends Bloc<JoblistEvent, JoblistState> {
  final log = Logger('JoblistBloc');

  Backend _backend;
  String _token;
  Cache cache;

  List<Job> _jobs;

  JoblistBloc(this._backend) {
    log.fine('$this started');
  }

  @override
  JoblistState get initialState => JoblistState.init();

  List<Job> get jobs => _jobs;

  @override
  void dispose() {
    log.fine('disposing of $this');
    super.dispose();
  }

  int getIndexById(int id) => _jobs.indexWhere((job) => job.id == id);

  @override
  Stream<JoblistState> mapEventToState(JoblistEvent event) async* {
    log.fine('Event: $event');

    /// go into busy state to show busyness
    yield JoblistState.busy();

    if (event is InitJobs) {
      _token = event.token;
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
        await _printJob(event.deviceId, ((event.id != null) ? event.id : _jobs[event.index].id));
        int index = getIndexById(event.id);
        if (!_jobs[index].jobOptions.keep) {
          _jobs.remove(index);
        }
        yield JoblistState.result(_jobs);
      } on ApiException catch (e) {
        yield JoblistState.exception(e);
      }
    } else if (event is DeleteJob) {
      try {
        await _deleteJob(((event.id != null) ? event.id : _jobs[event.index].id));
        yield JoblistState.result(_jobs);
      } on ApiException catch (e) {
        yield JoblistState.exception(e);
      }
    } else if (event is UpdateOptions) {
      try {
        await _putJobOptions(
          ((event.id != null) ? event.id : _jobs[event.index].id),
          event.options,
        );
        yield JoblistState.result(_jobs);
      } on ApiException catch (e) {
        yield JoblistState.exception(e);
      }
    } else if (event is RefreshOptions) {
      try {
        _getOptions((event.id != null) ? event.id : _jobs[event.index].id);
        yield JoblistState.result(_jobs);
      } on ApiException catch (e) {
        yield JoblistState.exception(e);
      }
    }
  }

  onDelete(int index) => dispatch(DeleteJob(index: index));

  onDeleteById(int id) => dispatch(DeleteJob(id: id));

  onPrint(String deviceId, int index) => dispatch(PrintJob(
        deviceId: deviceId,
        index: index,
      ));

  onPrintById(String deviceId, int id) => dispatch(PrintJob(
        deviceId: deviceId,
        id: id,
      ));

  onRefresh() => dispatch(RefreshJobs());

  onRefreshOptions(int index) => dispatch(RefreshOptions(index: index));

  onRefreshOptionsById(int id) => dispatch(RefreshOptions(id: id));

  onStart(String token) => dispatch(InitJobs(token));

  @override
  void onTransition(Transition<JoblistEvent, JoblistState> transition) {
    log.fine('State: ${transition.nextState}');
    if (transition.nextState.isResult) {
      try {
        (cache ?? null).set('jobs', _jobs);
      } catch (e) {
        log.severe('you should use caching with this BloC, pass it in the constructor');
      }
    }

    super.onTransition(transition);
  }

  onUpdateOptions(int index, JobOptions options) =>
      dispatch(UpdateOptions(options: options, index: index));

  onUpdateOptionsById(int id, JobOptions options) =>
      dispatch(UpdateOptions(options: options, id: id));

  Future<void> _deleteJob(int id) async {
    Request request = ApiRequest('DELETE', '/jobs/$id', _backend);
    request.headers['X-Api-Key'] = _token;

    log.finer('_deleteJob: $request');

    return await _backend.send(request).then(
      (response) async {
        log.finer('_deleteJob: ${response.statusCode}');
        if (response.statusCode == 205) {
          _jobs.removeWhere((Job job) => job.id == id);
        } else {
          throw ApiException(response.statusCode, info: 'received status code other than 205');
        }
      },
    );
  }

  Future<void> _getJob(int id) async {
    Request request = ApiRequest('GET', '/jobs/$id', _backend);
    request.headers['Accept'] = 'application/json';
    request.headers['X-Api-Key'] = _token;

    log.finer('_getJob: $request');

    return await _backend.send(request).then(
      (response) async {
        log.finer('_getSingle: ${response.statusCode}');
        if (response.statusCode == 200) {
          _jobs[getIndexById(id)] =
              Job.fromMap(json.decode(utf8.decode(await response.stream.toBytes())));
        } else {
          throw ApiException(response.statusCode, info: 'status code other than 200 received');
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
          _jobs = List.from(json.decode(utf8.decode(await response.stream.toBytes())).map(
            (value) {
              Job job = Job.fromMap(value);
              return job;
            },
          ));
          return;
        } else {
          throw ApiException(response.statusCode, info: 'status code other than 200 received');
        }
      },
    );
  }

  Future<void> _getOptions(int id) async {
    Request request = ApiRequest('GET', '/jobs/$id/options', _backend);
    request.headers['Accept'] = 'application/json';
    request.headers['X-Api-Key'] = _token;

    log.finer('_getOptions: $request');

    return await _backend.send(request).then(
      (response) async {
        log.finer('_getOptions: ${response.statusCode}');
        if (response.statusCode == 200) {
          _jobs[getIndexById(id)].jobOptions =
              JobOptions.fromMap(json.decode(utf8.decode(await response.stream.toBytes())));
        } else {
          throw ApiException(response.statusCode, info: 'status code other than 200 received');
        }
      },
    );
  }

  Future<void> _printJob(String deviceId, int id) async {
    Request request = ApiRequest(
      'POST',
      '/printers/$deviceId/queue',
      _backend,
      queryParameters: {'id': id.toString()},
    );
    request.headers['X-Api-Key'] = _token;

    log.finer('_printJob: $request');

    return await _backend.send(request).then(
      (response) async {
        log.finer('_printJob: ${response.statusCode}');
        if (response.statusCode == 202) {
        } else {
          throw ApiException(response.statusCode, info: 'status code other than 202 received');
        }
      },
    );
  }

  Future<void> _putJobOptions(int id, JobOptions options) async {
    Request request = ApiRequest('PUT', '/jobs/$id/options', _backend);

    request.headers['Accept'] = 'application/json';
    request.headers['Content-Type'] = 'application/json';
    request.headers['X-Api-Key'] = _token;

    request.bodyBytes = utf8.encode(json.encode(options.toMap()));

    log.finer('_putJobOptions: $request');

    return await _backend.send(request).then((response) async {
      if (response.statusCode == 205) {
        jobs[getIndexById(id)].jobOptions = options;
      } else {
        throw ApiException(response.statusCode, info: 'status code other than 205 received');
      }
    });
  }
}

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

  JoblistBloc(this._backend) : super(JoblistState.init()) {
    log.fine('$this started');
  }

  List<Job> get jobs => _jobs;

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
        await _printJob(event.deviceId, ((event.id != null) ? event.id : _jobs[event.index].id),
            options: event.options);
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
    } else if (event is DeleteAllJobs) {
      try {
        await _deleteAllJobs();
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
    } else if (event is CopyJob) {
      try {
        _copyJob(event.id, event.image);
      } on ApiException catch (e) {
        yield JoblistState.exception(e);
      }
    }
  }

  void onCopyById(int id, bool asImage) => this.add(CopyJob(id: id, image: asImage));

  void onDelete(int index) => this.add(DeleteJob(index: index));

  void onDeleteAll() => this.add(DeleteAllJobs());

  void onDeleteById(int id) => this.add(DeleteJob(id: id));

  void onPrint(String deviceId, int index, {JobOptions options}) => this.add(PrintJob(
        deviceId: deviceId,
        index: index,
        options: options,
      ));

  void onPrintById(String deviceId, int id, {JobOptions options}) => this.add(PrintJob(
        deviceId: deviceId,
        id: id,
        options: options,
      ));

  void onRefresh() => this.add(RefreshJobs());

  void onRefreshOptions(int index) => this.add(RefreshOptions(index: index));

  void onRefreshOptionsById(int id) => this.add(RefreshOptions(id: id));

  void onStart(String token) => this.add(InitJobs(token));

  @override
  void onTransition(Transition<JoblistEvent, JoblistState> transition) {
    log.fine('State: ${transition.nextState}');
    if (transition.nextState.isResult) {
      try {
        (cache ?? null).set('jobs', _jobs);
      } catch (e) {
        log.warning('you should use caching with this BloC, pass it in the constructor');
      }
    }

    super.onTransition(transition);
  }

  onUpdateOptions(int index, JobOptions options) =>
      this.add(UpdateOptions(options: options, index: index));

  onUpdateOptionsById(int id, JobOptions options) =>
      this.add(UpdateOptions(options: options, id: id));

  Future<void> _copyJob(int id, bool image) async {
    Request request = ApiRequest(
      'POST',
      '/jobs/$id',
      _backend,
      queryParameters: {'image': image.toString()},
    );
    request.headers['X-Api-Key'] = _token;

    log.finer('_copyJob: $request');

    return await _backend.send(request).then(
      (response) async {
        log.finer('_copyJob: ${response.statusCode}');
        if (response.statusCode == 202 || response.statusCode == 200) {
          return;
        } else {
          throw ApiException(response.statusCode,
              info: 'received status code other than 202 or 200');
        }
      },
    );
  }

  Future<void> _deleteAllJobs() async {
    Request request = ApiRequest('DELETE', '/jobs', _backend);
    request.headers['X-Api-Key'] = _token;

    log.finer('_deleteAllJobs: $request');

    return await _backend.send(request).then(
      (response) async {
        log.finer('_deleteAllJobs: ${response.statusCode}');
        if (response.statusCode == 205) {
          _jobs = [];
        } else {
          throw ApiException(response.statusCode, info: 'received status code other than 205');
        }
      },
    );
  }

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

  Future<void> _printJob(String deviceId, int id, {JobOptions options}) async {
    Request request = ApiRequest(
      'POST',
      '/printers/$deviceId/queue',
      _backend,
      queryParameters: {'id': id.toString()},
    );
    request.headers['X-Api-Key'] = _token;
    if (options != null) request.body = json.encode(options.toMap());

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

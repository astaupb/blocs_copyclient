import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

import '../models/backend.dart';
import '../models/job.dart';
import '../models/joboptions.dart';
import 'jobs_events.dart';
import 'jobs_state.dart';

class JobsBloc extends Bloc<JobsEvent, JobsState> {
  final log = Logger('JobsBloc');

  Backend _backend;
  String _token;

  List<Job> _jobs;

  JobsBloc(this._backend, this._token) {
    log.fine('$this started');
  }

  @override
  JobsState get initialState => JobsState.init();

  get jobs => _jobs;

  @override
  void dispose() {
    log.fine('disposing of $this');
    super.dispose();
  }

  @override
  Stream<JobsState> mapEventToState(JobsState state, JobsEvent event) async* {
    /// go into busy state to show busyness
    yield JobsState.busy();

    if (event is RefreshJobs || event is InitJobs) {
      try {
        await _getJobs();
        yield JobsState.result(_jobs);
      } catch (e) {
        yield JobsState.error(e.toString());
      }
    } else if (event is UploadJob) {
      try {
        await _uploadJob(event.file, event.filename, event.options);
        yield JobsState.result(_jobs);
      } catch (e) {
        yield JobsState.error(e.toString());
      }
    }
  }

  onRefresh() => dispatch(RefreshJobs());

  onStart() => dispatch(InitJobs());

  @override
  void onTransition(Transition<JobsEvent, JobsState> transition) {
    log.fine(transition.event);
    log.fine(transition.nextState);

    super.onTransition(transition);
  }

  onUpdateJob() => null;

  onUpload({@required File file}) => dispatch(UploadJob(file: file));

  /// request job list from backend route and update local list instance
  Future<void> _getJobs() async {
    Request request = ApiRequest('GET', '/jobs', _backend);
    request.headers['Accept'] = 'application/json';
    request.headers['X-Api-Key'] = _token;

    log.finer(request);

    return await _backend.send(request).then(
      (response) async {
        if (response.statusCode == 200) {
          _jobs = List.from(json
              .decode(utf8.decode(await response.stream.toBytes()))
              .map((value) => Job.fromMap(value)));
        } else {
          throw Exception('status code other than 200 received');
        }
      },
    );
  }

  Future<void> _getSingle(String uid) async {
    Request request = ApiRequest('GET', '/jobs/$uid', _backend);
    request.headers['Accept'] = 'application/json';
    request.headers['X-Api-Key'] = _token;

    log.finer(request);

    return await _backend.send(request).then(
      (response) async {
        if (response.statusCode == 200) {
          _jobs[_jobs.indexWhere((Job job) => job.uid == uid)] = Job.fromMap(
              json.decode(utf8.decode(await response.stream.toBytes())));
        } else {
          throw Exception('status code other than 200 received');
        }
      },
    );
  }

  Future<void> _uploadJob(
      File file, String filename, JobOptions options) async {
    Request request = ApiRequest('POST', '/jobs', _backend);
    request.headers['Accept'] = 'application/pdf';
    request.headers['Content-Type'] = 'application/pdf';
    request.headers['X-Api-Key'] = _token;
    request.body = file.readAsStringSync();

    log.finer(request);

    return await _backend.send(request).then(
      (response) async {
        if (response.statusCode == 202) {
          _jobs.add(Job(uid: utf8.decode(await response.stream.toBytes())));
        } else {
          throw Exception('status code other than 202 received');
        }
      },
    );
  }

  Future<void> _deleteJob(String uid) async {
    Request request = ApiRequest('DELETE', '/jobs/$uid', _backend);
    request.headers['X-Api-Key'] = _token;

    log.finer(request);

    return await _backend.send(request).then(
      (response) async {
        if (response.statusCode == 205) {
          _jobs.removeWhere((Job job) => job.uid == uid);
        } else {
          throw Exception('status code other than 205 received');
        }
      },
    );
  }
}

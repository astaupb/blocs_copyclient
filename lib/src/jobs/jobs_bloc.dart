import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

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

  int getIndexByUid(String uid) => _jobs.indexWhere((job) => job.uid == uid);

  @override
  Stream<JobsState> mapEventToState(JobsState state, JobsEvent event) async* {
    /// go into busy state to show busyness
    yield JobsState.busy();

    if (event is InitJobs) {
      try {
        await _getJobs();
        yield JobsState.result(_jobs);
      } catch (e) {
        yield JobsState.error(e.toString());
      }
    } else if (event is RefreshJobs) {
      try {
        if (event.index != null)
          await _getJobs();
        else
          await _getSingle(_jobs[event.index].uid);
        yield JobsState.result(_jobs);
      } catch (e) {
        yield JobsState.error(e.toString());
      }
    } else if (event is GetPreviews) {
      try {
        await _getPreviews(event.uid);
        yield JobsState.result(_jobs);
      } catch (e) {
        yield JobsState.error(e.toString());
      }
    } else if (event is UploadJob) {
      try {
        await _uploadJob(event.file, event.filename, event.options);

        /// TODO: only get single job by uid here and/or wait better
        await _getJobs();
        yield JobsState.result(_jobs);
      } catch (e) {
        yield JobsState.error(e.toString());
      }
    } else if (event is PrintJob) {
      try {
        await _printJob(event.deviceId,
            ((event.uid != null) ? event.uid : _jobs[event.index].uid));
        int index = getIndexByUid(event.uid);
        if (!_jobs[index].jobOptions.keep) {
          _jobs.remove(index);
        }
        yield JobsState.result(_jobs);
      } catch (e) {
        yield JobsState.error(e.toString());
      }
    } else if (event is DeleteJob) {
      try {
        await _deleteJob(
            ((event.uid != null) ? event.uid : _jobs[event.index].uid));
        yield JobsState.result(_jobs);
      } catch (e) {
        yield JobsState.error(e.toString());
      }
    } else if (event is GetPdf) {
      try {
        await _getPdf(event.uid);
        yield JobsState.result(_jobs);
      } catch (e) {
        yield JobsState.error(e.toString());
      }
    }
  }

  onDelete(int index) => dispatch(DeleteJob(index: index));

  onDeleteByUid(String uid) => dispatch(DeleteJob(uid: uid));

  onGetPdf(String uid) => dispatch(GetPdf(uid));

  onGetPreview(String uid) => dispatch(GetPreviews(uid));

  onPrint(String deviceId, int index) => dispatch(PrintJob(
        deviceId: deviceId,
        index: index,
      ));

  onPrintbyUid(String deviceId, String uid) => dispatch(PrintJob(
        deviceId: deviceId,
        uid: uid,
      ));

  onRefresh() => dispatch(RefreshJobs());

  onRefreshSingle(int index) => dispatch(RefreshJobs(index: index));

  onStart() => dispatch(InitJobs());

  @override
  void onTransition(Transition<JobsEvent, JobsState> transition) {
    log.fine(transition.event);
    log.fine(transition.nextState);

    super.onTransition(transition);
  }

  onUpdateJob() => null;

  onUpload({@required File file, String filename, JobOptions options}) =>
      dispatch(UploadJob(
        file: file,
        filename: filename,
        options: options,
      ));

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

  Future<void> _getPdf(String uid) async {
    Request request = ApiRequest('GET', '/jobs/$uid/pdf', _backend);
    request.headers['Accept'] = 'application/pdf';
    request.headers['X-Api-Key'] = _token;

    log.finer(request);

    return await _backend.send(request).then(
      (response) async {
        if (response.statusCode == 200) {
          _jobs[_jobs.indexWhere((job) => job.uid == uid)].pdfBytes =
              await response.stream.toBytes();
        } else {
          throw Exception('status code other than 202 received');
        }
      },
    );
  }

  Future<void> _getPreviews(String uid) async {
    int index = getIndexByUid(uid);
    for (int i = 0; i < 4 && i < index; i++) {
      Request request = ApiRequest('GET', '/jobs/$uid/previews/$i', _backend);
      request.headers['Accept'] = 'image/jpeg';
      request.headers['X-Api-Key'] = _token;

      log.finer(request);

      await _backend.send(request).then(
        (response) async {
          if (response.statusCode == 200) {
            _jobs[index].previews[i] = await response.stream.toBytes();
          } else {
            throw Exception('status code other than 200 received');
          }
        },
      );
    }
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

  Future<void> _printJob(String deviceId, String uid) async {
    Request request = ApiRequest('POST', '/printers/$deviceId/queue', _backend);
    request.headers['X-Api-Key'] = _token;

    log.finer(request);

    return await _backend.send(request).then(
      (response) async {
        if (response.statusCode == 202) {
        } else {
          throw Exception('status code other than 202 received');
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
}

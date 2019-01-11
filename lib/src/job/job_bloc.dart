import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

import '../exceptions.dart';
import '../models/backend.dart';
import '../models/job.dart';
import '../models/joboptions.dart';
import 'job_events.dart';
import 'job_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  final Logger log = Logger('JobBloc');

  final Backend _backend;
  String _token;

  int id;
  Job job;

  JobBloc(this._backend);

  @override
  JobState get initialState => JobState.init();

  @override
  void dispose() {
    _backend.close();
  }

  @override
  Stream<JobState> mapEventToState(JobState state, JobEvent event) async* {
    log.fine('Event: ${event.runtimeType} $event');
    if (event is RefreshOptions) {
      try {
        await _getOptions(id);
        yield JobState.result(job);
      } on ApiException catch (e) {
        yield JobState.exception(e);
      }
    } else if (event is UpdateOptions) {
      try {
        await _putJobOptions(event.options);
        job.priceEstimation = _estimatePrice();
        yield JobState.result(job);
      } on ApiException catch (e) {
        yield JobState.exception(e);
      }
    } else if (event is InitJob) {
      _token = event.token;
      job = event.job;
      job.priceEstimation = _estimatePrice();
      id = job.id;
      yield JobState.result(job);
    } else if (event is Delete) {
      try {
        await _deleteJob();
        yield JobState.deleted();
      } on ApiException catch (e) {
        yield JobState.exception(e);
      }
    } else if (event is GetPreviews) {
      try {
        await _getPreview();
        yield JobState.result(job);
      } on ApiException catch (e) {
        yield JobState.exception(e);
      }
    }
  }

  onDelete() => dispatch(Delete());

  onGetPreview() => dispatch(GetPreviews());

  onRefresh() => dispatch(RefreshOptions());

  onSetOption() => print('take the job as it is');

  onStart(Job job, String token) => dispatch(InitJob(job, token));

  @override
  void onTransition(Transition<JobEvent, JobState> transition) {
    log.fine('State: ${transition.nextState}');
  }

  Future<void> _deleteJob() async {
    Request request = ApiRequest('DELETE', '/jobs/$id', _backend);
    request.headers['X-Api-Key'] = _token;

    log.finer('_deleteJob: $request');

    return await _backend.send(request).then(
      (response) async {
        log.finer('_getSingle: ${response.statusCode}');
        if (response.statusCode == 205) {
          job = null;
        } else {
          throw ApiException(response.statusCode,
              info: 'status code other than 200 received');
        }
      },
    );
  }

  int _estimatePrice({basePrice: 2}) {
    int _basePrice = basePrice;
    int _totalPages = job.jobInfo.pagecount;

    if (job.jobInfo.colored > 0) _basePrice = 10;

    if (job.jobOptions.a3 || job.jobInfo.a3) _basePrice *= 2;

    if (job.jobOptions.nup == 4 && _totalPages > 3) {
      _totalPages = _totalPages ~/ 4 + ((_totalPages % 4 > 0) ? 1 : 0);
    } else if (job.jobOptions.nup == 4 && _totalPages <= 4) {
      _totalPages = 1;
    }

    if (job.jobOptions.nup == 2 && _totalPages > 1)
      _totalPages = _totalPages ~/ 2 + _totalPages % 2;

    _basePrice *= (_totalPages * job.jobOptions.copies);

    return _basePrice;
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
          job = Job.fromMap(
              json.decode(utf8.decode(await response.stream.toBytes())));
        } else {
          throw ApiException(response.statusCode,
              info: 'status code other than 200 received');
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
          job.jobOptions = JobOptions.fromMap(
              json.decode(utf8.decode(await response.stream.toBytes())));
        } else {
          throw ApiException(response.statusCode,
              info: 'status code other than 200 received');
        }
      },
    );
  }

  Future<void> _getPreview() async {
    for (int i in Iterable.generate(job.jobInfo.pagecount)) {
      Request request =
          ApiRequest('GET', '/jobs/${job.id}/preview/$i', _backend);
      request.headers['Accept'] = 'image/jpeg';
      request.headers['X-Api-Key'] = _token;

      log.finer('_getPreview: $request');

      return await _backend.send(request).then(
        (response) async {
          log.finer('_getPreview: ${response.statusCode}');
          if (response.statusCode == 200) {
            job.previews.add(await response.stream.toBytes());
            job.hasPreview = true;
          } else {
            throw ApiException(response.statusCode,
                info: 'status code other than 200 received');
          }
        },
      );
    }
  }

  Future<void> _putJobOptions(JobOptions options) async {
    Request request = ApiRequest('PUT', '/jobs/$id/options', _backend);

    request.headers['Accept'] = 'application/json';
    request.headers['Content-Type'] = 'application/json';
    request.headers['X-Api-Key'] = _token;

    request.bodyBytes = utf8.encode(job.jobOptions.toString());

    return await _backend.send(request).then((response) async {
      if (response.statusCode == 205) {
        job.jobOptions = options;
      } else {
        throw ApiException(response.statusCode,
            info: 'status code other than 205 received');
      }
    });
  }
}

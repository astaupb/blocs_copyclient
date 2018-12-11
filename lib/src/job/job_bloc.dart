import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

import '../models/backend.dart';
import '../models/job.dart';
import '../models/joboptions.dart';
import '../exceptions.dart';
import 'job_events.dart';
import 'job_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  final Logger log = Logger('JobBloc');

  final Backend _backend;
  String _token;

  int id;
  Job job;

  JobBloc(this._backend);

  onStart(Job job, String token) => dispatch(InitJob(job, token));

  onRefresh() => dispatch(RefreshOptions());

  onSetOption() => print('take the job as it is');

  @override
  JobState get initialState => JobState.init();

  int _estimatePrice({basePrice: 2}) {
    int _basePrice = basePrice;
    int _totalPages = job.jobInfo.pagecount;

    if (job.jobInfo.color) _basePrice = 10;

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

  @override
  Stream<JobState> mapEventToState(JobState state, JobEvent event) async* {
    if (event is RefreshOptions) {
      try {
        _getOptions(id);
        yield JobState.result(job);
      } on ApiException catch (e) {
        yield JobState.exception(e);
      }
    } else if (event is UpdateOptions) {
      job.jobOptions = event.options;
      job.priceEstimation = _estimatePrice();
    } else if (event is InitJob) {
      _token = event.token; 
      job = event.job;
      job.priceEstimation = _estimatePrice();
      id = job.id;
    }
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

  Future<void> _updateJobOptions(JobOptions options) async {
    Request request = ApiRequest('PUT', '/jobs/$id/options', _backend);

    request.headers['Accept'] = 'application/json';
    request.headers['Content-Type'] = 'application/json';
    request.headers['X-Api-Key'] = _token;

    request.body = job.jobOptions.toString();

    return await _backend.send(request).then(
      (response) async {
        if (response.statusCode == 205) {
          job.jobOptions = options;
        } else {
          throw ApiException(response.statusCode,
              info: 'status code other than 205 received');
        }
      });

  }

  Future<void> _getPreview() async {
    for (int i = 0; i < 4 && i < job.jobInfo.pagecount; i++) {
      Request request =
          ApiRequest('GET', '/jobs/${job.id}/previews/$i', _backend);
      request.headers['Accept'] = 'image/jpeg';
      request.headers['X-Api-Key'] = _token;

      log.finer('_getPreview: $request');

      await _backend.send(request).then(
        (response) async {
          log.finer('_getPreview: ${response.statusCode}');
          if (response.statusCode == 200) {
            job.previews[i] = await response.stream.toBytes();
          } else {
            throw ApiException(response.statusCode,
                info: 'status code other than 200 received');
          }
        },
      );
    }
  }
}

import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

import '../models/backend.dart';
import '../models/job.dart';
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

  onRefresh() => dispatch(RefreshJob());

  onSetOption() => print('take the job as it is');

  @override
  JobState get initialState => JobState.init();

  @override
  Stream<JobState> mapEventToState(JobState state, JobEvent event) async* {
    if (event is RefreshJob) {
      try {
        _getJob(id);
        yield JobState.result(job);
      } on ApiException catch (e) {
        yield JobState.exception(e);
      }
    } else if (event is InitJob) {
      _token = event.token; 
      job = event.job;
      id = job.id;
    }
  }

  Future<void> _getJob(int id) async {
    Request request = ApiRequest('GET', '/jobs/$id', _backend);
    request.headers['Accept'] = 'application/json';
    request.headers['X-Api-Key'] = _token;

    log.finer('_getSingle: $request');

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

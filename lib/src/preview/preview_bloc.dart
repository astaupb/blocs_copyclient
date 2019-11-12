import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

import '../../exceptions.dart';
import '../models/backend.dart';
import '../models/job.dart';
import 'preview_events.dart';
import 'preview_state.dart';

class PreviewBloc extends Bloc<PreviewEvent, PreviewState> {
  final log = Logger('PreviewBloc');

  final Backend _backend;
  String _token;

  List<PreviewSet> previewSets = [];

  PreviewBloc(this._backend) {
    log.fine('$this started');
  }

  @override
  PreviewState get initialState => PreviewState.init();

  @override
  Stream<PreviewState> mapEventToState(PreviewEvent event) async* {
    log.fine('Event: $event');
    if (event is InitPreviews) {
      _token = event.token;
    } else if (event is GetPreview) {
      try {
        await _getPreview(event.job);
        yield PreviewState.result(previewSets);
      } on ApiException catch (e) {
        yield PreviewState.exception(e);
      }
    }
  }

  void onGetPreview(Job job) => this.add(GetPreview(job));

  void onStart(String token) => this.add(InitPreviews(token));

  @override
  void onTransition(Transition<PreviewEvent, PreviewState> transition) {
    log.fine('State: ${transition.nextState}');
    super.onTransition(transition);
  }

  Future<void> _getPreview(Job job) async {
    if (previewSets.any((PreviewSet set) => set.jobId == job.id)) return;
    List<List<int>> files = [];
    for (int i = 0; i < ((job.jobInfo.pagecount > 4) ? 4 : job.jobInfo.pagecount); i++) {
      Request request = ApiRequest('GET', '/jobs/${job.id}/preview/$i', _backend);
      request.headers['Accept'] = 'image/jpeg';
      request.headers['X-Api-Key'] = _token;

      log.finer('_getPreview: $request');

      await _backend.send(request).then(
        (response) async {
          log.finer('_getPreview: ${response.statusCode}');
          if (response.statusCode == 200) {
            files.add(await response.stream.toBytes());
          } else {
            throw ApiException(response.statusCode, info: 'status code other than 200 received');
          }
        },
      );
    }
    previewSets.add(PreviewSet(job.id, files));
    return;
  }
}

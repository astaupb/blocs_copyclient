import 'dart:core';

import '../common.dart';
import '../../exceptions.dart';

class PreviewSet {
  final int jobId;
  final List<List<int>> previews;

  PreviewSet(this.jobId, this.previews);

  Map<String, dynamic> toMap() => {
        'jobId': jobId,
        'previews': previews.length,
      };

  @override
  String toString() => toMap().toString();
}

class PreviewState extends ResultState<List<PreviewSet>> {
  PreviewState({
    List<PreviewSet> previewSets,
    ApiException error,
    bool isInit = false,
    bool isBusy = false,
    bool isResult = false,
    bool isException = false,
  }) : super(
          value: previewSets,
          error: error,
          isInit: isInit,
          isBusy: isBusy,
          isResult: isResult,
          isException: isException,
        );

  factory PreviewState.busy() => PreviewState(isBusy: true);

  factory PreviewState.exception(ApiException e) =>
      PreviewState(isException: true, error: e);

  factory PreviewState.init() => PreviewState(isInit: true);

  factory PreviewState.result(List<PreviewSet> previewSets) =>
      PreviewState(isResult: true, previewSets: previewSets);

  Map<String, dynamic> toMap() => {
        'previewSets': (value != null) ? value : 'null',
        'error': (error != null) ? error : 'null',
        'isInit': isInit,
        'isBusy': isBusy,
        'isResult': isResult,
        'isException': isException
      };

  @override
  String toString() => toMap().toString();
}

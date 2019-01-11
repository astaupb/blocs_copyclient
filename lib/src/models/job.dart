import 'dart:typed_data';

import 'jobinfo.dart';
import 'joboptions.dart';

const String scope = 'Job:';

class Job {
  final int id;
  final int timestamp;
  JobOptions jobOptions;
  final JobInfo jobInfo;
  int priceEstimation;

  Uint8List pdfBytes;
  List<List<int>> previews = [];
  bool hasPreview = false;

  Job({this.id, this.timestamp, this.jobOptions, this.jobInfo});

  factory Job.fromMap(Map<String, dynamic> jobs) {
    JobOptions _jobOptions;
    JobInfo _jobInfo;

    try {
      _jobOptions = JobOptions.fromMap(jobs['options']);
    } catch (e) {
      print('$scope Job-Options map is damaged or incomplete');
    }
    try {
      _jobInfo = JobInfo.fromMap(jobs['info']);
    } catch (e) {
      print('$scope Job-Info map is damaged or incomplete');
    }

    return Job(
      id: jobs['id'],
      timestamp: jobs['timestamp'],
      jobOptions: _jobOptions,
      jobInfo: _jobInfo,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp,
        'info': jobInfo.toMap(),
        'options': jobOptions.toMap(),
        'estimation': priceEstimation,
        'hasPreview': hasPreview,
        'previews': previews?.length,
      };

  @override
  String toString() => toMap().toString();
}

import 'jobinfo.dart';
import 'joboptions.dart';

const String scope = 'Job:';

class Job {
  final String uid;
  final int timestamp;
  final int userId;
  final JobOptions jobOptions;
  final JobInfo jobInfo;

  Job({this.uid, this.timestamp, this.userId, this.jobOptions, this.jobInfo});

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
      uid: jobs['uid'],
      timestamp: jobs['timestamp'],
      userId: jobs['user_id'],
      jobOptions: _jobOptions,
      jobInfo: _jobInfo,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'timestamp': timestamp,
        'user_id': userId,
        'info': jobInfo.toMap(),
        'options': jobOptions.toMap()
      };

  @override
  String toString() => toMap().toString();
}

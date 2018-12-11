import 'package:meta/meta.dart';

import '../models/job.dart';

class GetPreviews extends JobEvent {}

class InitJob extends JobEvent {
  final Job job;
  final String token;

  InitJob({@required this.job, @required this.token});

  Map<String, dynamic> toMap() => {
    'job':  (job ?? Job()).toMap(),
    'token': token,
  };

  @override
  String toString() => toMap().toString();
}

abstract class JobEvent {}

class RefreshJob extends JobEvent {}

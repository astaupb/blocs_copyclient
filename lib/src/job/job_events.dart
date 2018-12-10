import '../models/job.dart';

abstract class JobEvent {}

class RefreshJob extends JobEvent {}

class InitJob extends JobEvent {
  final Job job;

  InitJob({this.job});

  Map<String, dynamic> toMap() => (job ?? Job()).toMap();

  @override
  String toString() => toMap().toString();
}

class GetPreviews extends JobEvent {}
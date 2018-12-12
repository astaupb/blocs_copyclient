import '../models/job.dart';
import '../models/joboptions.dart';

class Delete extends JobEvent {}

class GetPreviews extends JobEvent {}

class InitJob extends JobEvent {
  final Job job;
  final String token;

  InitJob(this.job,this.token);

  Map<String, dynamic> toMap() => {
    'job':  (job ?? Job()).toMap(),
    'token': token,
  };

  @override
  String toString() => toMap().toString();
}

abstract class JobEvent {}

class RefreshOptions extends JobEvent {}

class UpdateOptions extends JobEvent {
  final JobOptions options;

  UpdateOptions(this.options);
}

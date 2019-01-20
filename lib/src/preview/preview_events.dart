import '../models/job.dart';

class GetPreview extends PreviewEvent {
  final Job job;

  GetPreview(this.job);

  Map<String, dynamic> toMap() => {'job': job.toMap()};

  @override
  String toString() => toMap().toString();
}

class InitPreviews extends PreviewEvent {
  final String token;

  InitPreviews(this.token);

  Map<String, dynamic> toMap() => {'token': token};

  @override
  String toString() => toMap().toString();
}

abstract class PreviewEvent {}

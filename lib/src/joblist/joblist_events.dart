import 'package:meta/meta.dart';

import '../models/joboptions.dart';

/// [DeleteJob] _needs_ to have either [id] or [index] set
class DeleteJob extends JoblistEvent {
  final int id;
  final int index;

  DeleteJob({this.id, this.index});

  Map<String, dynamic> toMap() => {'id': id, 'index': index};

  @override
  String toString() => toMap().toString();
}

class DeleteAllJobs extends JoblistEvent {}

class InitJobs extends JoblistEvent {
  final String token;

  InitJobs(this.token);

  Map<String, dynamic> toMap() => {'token': token};

  @override
  String toString() => toMap().toString();
}

abstract class JoblistEvent {}

/// [PrintJob] _needs_ to have either [id] or [index] set
class PrintJob extends JoblistEvent {
  final String deviceId;
  final int id;
  final int index;

  final JobOptions options;

  PrintJob({@required this.deviceId, this.id, this.index, this.options});

  Map<String, dynamic> toMap() => {
        'deviceId': deviceId,
        'id': id,
        'index': index,
        'options': options,
      };

  @override
  String toString() => toMap().toString();
}

class CopyJob extends JoblistEvent {
  final int id;
  final bool image;

  CopyJob({@required this.id, this.image});

  Map<String, dynamic> toMap() => {
        'id': id,
        'image': image,
      };

  @override
  String toString() => toMap().toString();
}

/// Demand refreshing all jobs, or if [index] is set only that one
class RefreshJobs extends JoblistEvent {}

class UpdateOptions extends JoblistEvent {
  final JobOptions options;
  final int index;
  final int id;

  UpdateOptions({@required this.options, this.id, this.index});

  Map<String, dynamic> toMap() => {
        'options': options.toMap(),
        'id': id,
        'index': index,
      };

  @override
  String toString() => toMap().toString();
}

class RefreshOptions extends JoblistEvent {
  final int index;
  final int id;

  RefreshOptions({this.id, this.index});

  Map<String, dynamic> toMap() => {
        'id': id,
        'index': index,
      };

  @override
  String toString() => toMap().toString();
}

import 'package:meta/meta.dart';
import '../models/backend.dart';

abstract class BackendEvent {}

class SetBackend extends BackendEvent {
  final Backend backend;

  SetBackend({@required this.backend});

  Map<String, dynamic> toMap() =>
      {'backend': (backend != null) ? backend.toMap() : {}};

  @override
  String toString() => toMap().toString();
}

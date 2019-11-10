import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:logging/logging.dart';

import '../models/backend.dart';
import 'backend_events.dart';
import 'backend_state.dart';

/// BLoC that stores or changes the current backend
class BackendBloc extends Bloc<BackendEvent, BackendState> {
  final log = Logger('BackendBloc');
  Backend _backend;

  BackendBloc() {
    log.fine('$this started');
  }

  get backend => _backend;

  @override
  get initialState => BackendState.init();

  @override
  Stream<BackendState> mapEventToState(BackendEvent event) async* {
    log.fine(event);
    if (event is SetBackend) {
      _backend = event.backend;
      yield BackendState.result(_backend);
    }
  }

  void onSetBackend(Backend backend) => this.add(SetBackend(backend: backend));

  @override
  void onTransition(Transition<BackendEvent, BackendState> transition) {
    log.fine(transition.nextState);
    super.onTransition(transition);
  }
}

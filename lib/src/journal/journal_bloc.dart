import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

import 'journal_events.dart';
import 'journal_state.dart';
import '../exceptions.dart';
import '../models/backend.dart';
import '../models/transaction.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final Logger log = Logger('JournalBloc');

  Backend _backend;
  String _token;

  List<Transaction> _journal;
  double _credit;

  JournalBloc() {
    log.fine('$this started');
  }

  @override
  get initialState => JournalState.init();

  @override
  Stream<JournalState> mapEventToState(
      JournalState state, JournalEvent event) async* {
    log.fine(event);
    yield JournalState.busy();

    if (event is RefreshJournal || event is InitJournal) {
      try {
        await _getJournal();
        await _getCredit();
        yield JournalState.result(
            JournalResult(credit: _credit, transactions: _journal));
      } on ApiException catch (e) {
        yield JournalState.exception(e);
      }
    }
  }

  @override
  void onTransition(Transition<JournalEvent, JournalState> transition) {
    log.fine(transition.nextState);

    super.onTransition(transition);
  }

  @override
  void dispose() {
    log.fine('disposing of $this');
    super.dispose();
  }

  Future<void> _getJournal() async {
    Request request = new ApiRequest('GET', '/journal', _backend);
    request.headers['Accept'] = 'application/json';
    request.headers['X-Api-Key'] = _token;

    log.finer('_getJournal $request');

    return await _backend.send(request).then(
      (response) async {
        log.finer('_getJournal: ${response.statusCode}');
        if (response.statusCode == 200) {
          _journal = List.from(json
              .decode(utf8.decode(await response.stream.toBytes()))
              .map((value) => Transaction.fromMap(value)));
        } else {
          throw ApiException(response.statusCode,
              info: 'status code other than 200 received');
        }
      },
    );
  }

  Future<void> _getCredit() async {
    Request request = new ApiRequest('GET', '/credit', _backend);
    request.headers['Accept'] = 'application/json';
    request.headers['X-Api-Key'] = _token;

    log.finer('_getCredit: $request');

    return await _backend.send(request).then(
      (response) async {
        log.finer('_getCredit: ${response.statusCode}');
        if (response.statusCode == 200) {
          _credit = json.decode(utf8.decode(await response.stream.toBytes()));
        } else {
          throw ApiException(response.statusCode,
              info: 'status code other than 200 received');
        }
      },
    );
  }
}

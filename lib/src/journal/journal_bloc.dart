import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:csv/csv.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

import '../../exceptions.dart';
import '../models/backend.dart';
import '../models/journal_result.dart';
import '../models/transaction.dart';
import 'journal_events.dart';
import 'journal_state.dart';

String journalToCsv(List<Transaction> journal) {
  return ListToCsvConverter().convert(List.from(journal.map((Transaction item) =>
      [(item.value / 100.0).toStringAsFixed(2), item.description, item.timestamp])));
}

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final Logger log = Logger('JournalBloc');

  Backend _backend;
  String _token;

  List<Transaction> _journal;
  int _credit;

  JournalBloc(this._backend) {
    log.fine('$this started');
  }

  String get csvJournal => journalToCsv(_journal);

  List<int> get csvJournalBytes => Uint16List.fromList(csvJournal.codeUnits);

  @override
  get initialState => JournalState.init();

  @override
  Stream<JournalState> mapEventToState(JournalEvent event) async* {
    log.fine(event);
    if (event is InitJournal) _token = event.token;

    if (event is RefreshJournal || event is InitJournal) {
      try {
        await _getJournal();
        await _getCredit();
        yield JournalState.result(JournalResult(credit: _credit, transactions: _journal));
      } on ApiException catch (e) {
        yield JournalState.exception(e);
      }
    } else if (event is AddTransaction) {
      try {
        await _postJournal(event.token);
        this.add(RefreshJournal());
      } on ApiException catch (e) {
        yield JournalState.exception(e);
      }
    }
  }

  void onAddTransaction(String token) => this.add(AddTransaction(token));

  void onRefresh() => this.add(RefreshJournal());

  void onStart(String token) => this.add(InitJournal(token));

  @override
  void onTransition(Transition<JournalEvent, JournalState> transition) {
    log.fine('State: ${transition.nextState}');

    super.onTransition(transition);
  }

  Future<void> _getCredit() async {
    Request request = ApiRequest('GET', '/journal/credit', _backend);
    request.headers['Accept'] = 'application/json';
    request.headers['X-Api-Key'] = _token;

    log.finer('_getCredit: $request');

    return await _backend.send(request).then(
      (response) async {
        log.finer('_getCredit: ${response.statusCode}');
        if (response.statusCode == 200) {
          _credit = json.decode(utf8.decode(await response.stream.toBytes()));
        } else {
          throw ApiException(response.statusCode, info: 'status code other than 200 received');
        }
      },
    );
  }

  Future<void> _getJournal() async {
    Request request = ApiRequest('GET', '/journal', _backend);
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
          throw ApiException(response.statusCode, info: 'status code other than 200 received');
        }
      },
    );
  }

  Future<void> _postJournal(String token) {
    log.fine('_postJournal: $token');
    ApiRequest request = ApiRequest('POST', '/journal', _backend);
    request.headers['Content-Type'] = 'application/json';
    request.headers['X-Api-Key'] = _token;

    request.body = token;

    log.finer('_postJournal: $request');

    return _backend.send(request).then((StreamedResponse response) {
      if (response.statusCode == 204) {
        return;
      } else {
        throw ApiException(response.statusCode, info: 'status code other than 204 received');
      }
    });
  }
}

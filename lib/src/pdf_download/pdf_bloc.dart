import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

import '../../exceptions.dart';
import '../models/backend.dart';
import '../models/pdf_file.dart';
import 'pdf_events.dart';
import 'pdf_state.dart';

class PdfBloc extends Bloc<PdfEvent, PdfState> {
  final Logger log = Logger('PdfBloc');

  final Backend _backend;
  String _token;

  List<PdfFile> _pdfs = [];

  PdfBloc(this._backend) : super(PdfState.init()) {
    log.fine('$this started');
  }

  @override
  Stream<PdfState> mapEventToState(PdfEvent event) async* {
    log.fine('Event: $event');

    if (event is InitPdf) {
      _token = event.token;
    }

    if (event is GetPdf) {
      yield PdfState.busy();
      try {
        await _getPdf(event.id);
        yield PdfState.result(_pdfs);
      } on ApiException catch (e) {
        yield PdfState.exception(e);
      }
    }
  }

  void onGetPdf(int id) => this.add(GetPdf(id));

  void onStart(String token) => this.add(InitPdf(token));

  @override
  void onTransition(Transition<PdfEvent, PdfState> transition) {
    log.finer('State: ${transition.nextState}');

    super.onTransition(transition);
  }

  Future<void> _getPdf(int id) async {
    Request request = ApiRequest('GET', '/jobs/$id/pdf', _backend);
    request.headers['Accept'] = 'application/pdf';
    request.headers['X-Api-Key'] = _token;

    log.finer('_getPdf: $request');

    if (!_pdfs.contains((PdfFile pdf) => pdf.id == id)) {
      return await _backend.send(request).then(
        (response) async {
          log.finer('_getPdf: ${response.statusCode}');
          if (response.statusCode == 200) {
            _pdfs.add(PdfFile(await response.stream.toBytes(), id));
            return;
          } else {
            throw ApiException(response.statusCode, info: 'status code other than 200 received');
          }
        },
      );
    } else
      return;
  }
}

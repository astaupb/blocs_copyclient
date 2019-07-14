import '../../exceptions.dart';
import '../common.dart';
import '../models/token.dart';

class TokensState extends ResultState<List<Token>> {
  TokensState({
    List<Token> tokens,
    ApiException error,
    bool isInit = false,
    bool isBusy = false,
    bool isException = false,
    bool isResult = false,
  }) : super(
          value: tokens,
          error: error,
          isInit: isInit,
          isBusy: isBusy,
          isResult: isResult,
          isException: isException,
        );

  factory TokensState.busy() => TokensState(isBusy: true);

  factory TokensState.exception(ApiException e) => TokensState(isException: true, error: e);

  factory TokensState.init() => TokensState(isInit: true);

  factory TokensState.result(List<Token> tokens) => TokensState(tokens: tokens, isResult: true);
}

abstract class CommonState {
  final String err;

  final bool isInit;
  final bool isBusy;
  final bool isError;

  CommonState({
    this.err,
    this.isInit,
    this.isBusy ,
    this.isError,
  });
}

abstract class ResultState<T> extends CommonState {
  /// value the result holds 
  final T value;

  /// state identifier
  final bool isResult;

  ResultState({
    this.isResult,
    this.value,
    String err,
    bool isInit,
    bool isBusy,
    bool isError,
  }) : super(
          err: err,
          isInit: isInit,
          isBusy: isBusy,
          isError: isError,
        );
}

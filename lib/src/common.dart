abstract class CommonState {
  final Exception error;

  final bool isInit;
  final bool isBusy;
  final bool isException;

  CommonState({
    this.error,
    this.isInit,
    this.isBusy,
    this.isException,
  });

  Map<String, dynamic> toMap() => {
    'error': error,
    'isInit': isInit,
    'isBusy': isBusy,
    'isException': isException,
  };
}

abstract class ResultState<T> extends CommonState {
  /// value the result holds
  final T value;

  /// state identifier
  final bool isResult;

  ResultState({
    this.isResult,
    this.value,
    Exception error,
    bool isInit,
    bool isBusy,
    bool isException,
  }) : super(
          error: error,
          isInit: isInit,
          isBusy: isBusy,
          isException: isException,
        );

  Map<String, dynamic> toMap() => {
    'value': value,
  }..addAll(super.toMap());

  @override
  String toString() => toMap().toString();
}

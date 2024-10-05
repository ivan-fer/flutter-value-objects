import 'value_failure.dart';

class UnexpectedValueError extends Error {
  final ValueFailure valueFailure;

  UnexpectedValueError(this.valueFailure);

  @override
  String toString() => Error.safeToString(
        'Find no recoverable error. '
        'Terminate app. '
        'This was the error: $valueFailure',
      );
}

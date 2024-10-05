import 'package:fpdart/fpdart.dart';

import 'value_failure.dart';
import 'value_object.dart';

/// Validator function used in Form Fields & passing in value objects.
/// A function that return null if a ValueObject
/// is valid or a failure text if not.
typedef FnValidate = String? Function<T>(Either<ValueFailure, T>)?;

/// Validate a Single Line Object
/// return null if [value] is in valid state or a failure description
String? validateGeneralSingleLine<T>(Either<ValueFailure, T> value) {
  return value.fold(
    (f) => f.maybeMap(
      strEmpty: (s) => 'Text cannot be empty',
      strMultiline: (s) => 'Text must be in one line',
      strMaxLength: (s) => 'Text exceed length. '
          'Max allowed: ${s.maxAllow}. '
          'Text length: ${s.total}',
      orElse: () => null,
    ),
    (_) => null,
  );
}

/// Validate a Multiple Line Object
/// return null if [value] is in valid state or a failure description
String? validateGeneralMultipleLine<T>(Either<ValueFailure, T> value) =>
    value.fold(
      (f) => f.maybeMap(
        strEmpty: (_) => 'Text cannot be empty',
        strMaxLength: (s) => 'Text exceed length. '
            'Max allowed: ${s.maxAllow}. '
            'Text length: ${s.total}',
        orElse: () => null,
      ),
      (_) => null,
    );

/// [input] cannot be empty
Either<ValueFailure, String> validatorStringIsEmpty(String input) =>
    input.isEmpty ? left(const ValueFailure.strEmpty()) : right(input);

/// [input] cannot exceed [max] length
Either<ValueFailure, String> validatorStringExceedMaxLength(
        String input, int max) =>
    input.length > max
        ? left(ValueFailure.strMaxLength(maxAllow: max, total: input.length))
        : right(input);

/// [input] cannot be less than [min] length
Either<ValueFailure, String> validatorStringExceedMinLength(
        String input, int min) =>
    input.length < min
        ? left(ValueFailure.strMinLength(minAllow: min, total: input.length))
        : right(input);

/// [input] has to be one line
Either<ValueFailure, String> validatorStringIsMultiline(String input) =>
    input.contains('\n')
        ? left(const ValueFailure.strMultiline())
        : right(input);

/// only accept letters, commas, periods & -
Either<ValueFailure, String> validateTextSimpleFormat(String input) {
  input = input.trim();
  const name = r"^[\p{L} ,.'-]*$";
  if (!RegExp(name, caseSensitive: false, unicode: true, dotAll: true)
      .hasMatch(input)) {
    return left(const ValueFailure.invalid());
  }
  return right(input);
}

/// Manage a text in a single line, non empty & with a max length
class ValueSingleLine extends ValueObject<String> {
  @override
  final Either<ValueFailure, String> value;

  final FnValidate fnValidate;

  factory ValueSingleLine(
    String input, {
    int max = 125,
    FnValidate customValidate,
  }) =>
      ValueSingleLine._(validator(input, max), customValidate);

  const ValueSingleLine._(this.value, this.fnValidate);

  @override
  String? validate() => fnValidate != null
      ? fnValidate!(value)
      : validateGeneralSingleLine(value);

  static Either<ValueFailure, String> validator(String input, int max) =>
      validatorStringIsEmpty(input.trim())
          .flatMap((a) => validatorStringExceedMaxLength(a, max))
          .flatMap(validatorStringIsMultiline);
}

/// Manage an optional text. If exist, it behave as a [ValueSingleLine]
class ValueOptionSingleLine extends ValueObject<Option<String>> {
  @override
  final Either<ValueFailure, Option<String>> value;

  /// return null if object doesn't exist or [getOrCrash] if exist.
  String? get valueOrCrash => getOrCrash.fold(() => null, (s) => s);

  final FnValidate fnValidate;

  factory ValueOptionSingleLine(
    Option<String> input, {
    int max = 125,
    FnValidate customValidate,
  }) {
    return ValueOptionSingleLine._(
      input.fold(
        () => right(none()),
        (a) {
          final v = ValueSingleLine(a, max: max);
          return v.value.fold(
            (l) => left(l),
            (r) => right(some(r)),
          );
        },
      ),
      customValidate,
    );
  }

  const ValueOptionSingleLine._(this.value, this.fnValidate);

  @override
  String? validate() => fnValidate != null
      ? fnValidate!(value)
      : validateGeneralSingleLine(value);
}

/// Manage a text that can have multiple lines, non empty & with a max length
class ValueMultipleLine extends ValueObject<String> {
  @override
  final Either<ValueFailure, String> value;

  final FnValidate fnValidate;

  factory ValueMultipleLine(
    String input, {
    int max = 600,
    FnValidate customValidate,
  }) {
    return ValueMultipleLine._(validator(input, max), customValidate);
  }

  const ValueMultipleLine._(this.value, this.fnValidate);

  @override
  String? validate() => fnValidate != null
      ? fnValidate!(value)
      : validateGeneralMultipleLine(value);

  static Either<ValueFailure, String> validator(String input, int max) =>
      validatorStringIsEmpty(input.trim())
          .flatMap((a) => validatorStringExceedMaxLength(a, max));
}

/// Manage an optional text. If exist, it behave as a [ValueMultipleLine]
class ValueOptionMultipleLine extends ValueObject<Option<String>> {
  @override
  final Either<ValueFailure, Option<String>> value;

  /// return null if object doesn't exist or [getOrCrash] if exist.
  String? get valueOrCrash => getOrCrash.fold(() => null, (s) => s);

  final FnValidate fnValidate;

  factory ValueOptionMultipleLine(
    Option<String> input, {
    int max = 600,
    FnValidate customValidate,
  }) {
    return ValueOptionMultipleLine._(
      input.fold(
        () => right(none()),
        (a) {
          final v = ValueMultipleLine(a, max: max);
          return v.value.fold(
            (l) => left(l),
            (r) => right(some(r)),
          );
        },
      ),
      customValidate,
    );
  }

  const ValueOptionMultipleLine._(this.value, this.fnValidate);

  @override
  String? validate() => fnValidate != null
      ? fnValidate!(value)
      : validateGeneralMultipleLine(value);
}

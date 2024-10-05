import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import 'errors.dart';
import 'value_failure.dart';

@immutable
abstract class ValueObject<T> {
  const ValueObject();

  Either<ValueFailure, T> get value;

  /// return the value or throw a fatal exception
  /// Throws [UnexpectedValueError] containing the [ValueFailure]
  T get getOrCrash => value.getOrElse((f) => throw UnexpectedValueError(f));

  /// return the value or null if failure
  T? get getOrNull => value.fold((f) => null, (r) => r);

  /// return an option with a failure or none
  Option<ValueFailure> failureOption() => value.fold(
        (l) => some(l),
        (_) => none(),
      );

  /// check if this object is valid or not
  bool get isValid => value.isRight();

  /// Get info about an error, if any, or null if this object is valid
  String? validate();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValueObject<T> &&
          runtimeType == other.runtimeType &&
          other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '$value';
}

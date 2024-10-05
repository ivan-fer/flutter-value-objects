import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'value_failure.dart';
import 'value_object.dart';
import 'utils.dart';

/// Manage a [DateTime] that must be in a range
/// Default range: min 1900, max 2100
class ValueWhen extends ValueObject<DateTime> {
  @override
  final Either<ValueFailure, DateTime> value;

  factory ValueWhen(
    DateTime input, {
    Option<DateTime> minDate = const None(),
    Option<DateTime> maxDate = const None(),
  }) {
    final defaultMinDate = minDate.getOrElse(() => DateTime(1900));
    final defaultMaxDate = maxDate.getOrElse(() => DateTime(2100));
    return ValueWhen._(
      validator(input, defaultMinDate, defaultMaxDate),
    );
  }

  const ValueWhen._(this.value);

  @override
  String? validate() => value.fold(
        (f) => f.maybeMap(
          dateOutRange: (s) =>
              'Date is out of range, min: ${s.min.year}, max: ${s.max.year}',
          orElse: () => null,
        ),
        (_) => null,
      );

  static Either<ValueFailure, DateTime> validator(
      DateTime input, DateTime min, DateTime max) {
    /// cannot be out of range
    if (input.isBefore(min) || input.isAfter(max)) {
      return left(ValueFailure.dateOutRange(min: min, max: max));
    }

    /// everything is ok
    return right(input);
  }
}

/// Manage an optional [DateTime].
/// If exist, it must have between min & max dates.
class ValueOptionWhen extends ValueObject<Option<DateTime>> {
  @override
  final Either<ValueFailure, Option<DateTime>> value;

  factory ValueOptionWhen(
    Option<DateTime> input, {
    Option<DateTime> minDate = const None(),
    Option<DateTime> maxDate = const None(),
  }) {
    return ValueOptionWhen._(input.fold(
      () => right(none()),
      (a) {
        final v = ValueWhen(a, minDate: minDate, maxDate: minDate);
        return v.value.fold(
          (f) => left(f),
          (d) => right(some(d)),
        );
      },
    ));
  }

  const ValueOptionWhen._(this.value);

  @override
  String? validate() => value.fold(
        (f) => f.maybeMap(
          dateOutRange: (s) =>
              'Date is out of range, min: ${s.min}, max: ${s.max}',
          orElse: () => null,
        ),
        (_) => null,
      );
}

/// Manage a [Duration] that must be in a range
/// Default range: min 10 minutes, max 24 hours
class ValueDuration extends ValueObject<Duration> {
  @override
  final Either<ValueFailure, Duration> value;

  factory ValueDuration(
    Duration input, {
    Duration minDur = const Duration(minutes: 10),
    Duration maxDur = const Duration(hours: 24),
  }) {
    return ValueDuration._(
      validator(input, minDur, maxDur),
    );
  }

  const ValueDuration._(this.value);

  @override
  String? validate() => value.fold(
        (f) => f.maybeMap(
          durationOutRange: (s) =>
              'Duration is out of range, min: ${s.min}, max: ${s.max}',
          orElse: () => null,
        ),
        (_) => null,
      );

  static Either<ValueFailure, Duration> validator(
      Duration input, Duration min, Duration max) {
    if (input < min || input > max) {
      return left(ValueFailure.durationOutRange(min: min, max: max));
    }

    /// everything is ok
    return right(input);
  }
}

/// 2. Puede ocurrir en días diferentes. start debe ser anterior que end
/// Manage a [DateTimeRange] that must be in a range
/// Default limits are from 1900 to 2100
class ValueWhenRange extends ValueObject<DateTimeRange> {
  @override
  final Either<ValueFailure, DateTimeRange> value;

  DateTime get start => getOrCrash.start;
  DateTime get end => getOrCrash.end;

  factory ValueWhenRange(
    DateTimeRange input, {
    /// min & max of this range
    Option<DateTimeRange> minMax = const None(),
  }) {
    final defaultMinMax = minMax.getOrElse(
        () => DateTimeRange(start: DateTime(1900), end: DateTime(2100)));

    return ValueWhenRange._(validator(input, defaultMinMax));
  }

  /// return a versión that has a 'out of range' failure
  factory ValueWhenRange.failure() =>
      ValueWhenRange(DateTimeRange(start: DateTime(0), end: DateTime(1)));

  const ValueWhenRange._(this.value);

  @override
  String? validate() => value.fold(
        (f) => f.maybeMap(
          dateOutRange: (s) =>
              'Date Range is out of range, min: ${s.min}, max: ${s.max}',
          orElse: () => null,
        ),
        (_) => null,
      );

  /// Chequea si dos se solapan
  bool overlap(ValueWhenRange other) {
    return getOrCrash.overlap(other.getOrCrash);
  }

  static Either<ValueFailure, DateTimeRange> validator(
      DateTimeRange input, DateTimeRange minMax) {
    /// 2. must be in range
    if (input.inRange(minMax)) {
      return left(
          ValueFailure.dateOutRange(min: minMax.start, max: minMax.end));
    }

    /// everything is ok
    return right(input);
  }
}

/// Manage a [DateTimeRange] that must be in a range & start & end are in the same Date
/// Default limits are from 1900 to 2100
class ValueWhenDayRange extends ValueObject<DateTimeRange> {
  @override
  final Either<ValueFailure, DateTimeRange> value;

  DateTime get date => DateTime(
      getOrCrash.start.year, getOrCrash.start.month, getOrCrash.start.day);
  TimeOfDay get start => TimeOfDay.fromDateTime(getOrCrash.start);
  TimeOfDay get end => TimeOfDay.fromDateTime(getOrCrash.end);

  factory ValueWhenDayRange(
    DateTimeRange input, {
    /// min & max of this range
    Option<DateTimeRange> minMax = const None(),
  }) {
    final defaultMinMax = minMax.getOrElse(
        () => DateTimeRange(start: DateTime(1900), end: DateTime(2100)));

    return ValueWhenDayRange._(validator(input, defaultMinMax));
  }

  /// return a versión that has a 'out of range' failure
  factory ValueWhenDayRange.failure() =>
      ValueWhenDayRange(DateTimeRange(start: DateTime(0), end: DateTime(1)));

  const ValueWhenDayRange._(this.value);

  @override
  String? validate() => value.fold(
        (f) => f.maybeMap(
          dateRangeNotSameDay: (s) => 'Range must occurs in the same day',
          dateOutRange: (s) =>
              'Date Range is out of range, min: ${s.min}, max: ${s.max}',
          orElse: () => null,
        ),
        (_) => null,
      );

  /// Chequea si dos se solapan
  bool overlap(ValueWhenDayRange other) {
    return getOrCrash.overlap(other.getOrCrash);
  }

  static Either<ValueFailure, DateTimeRange> validator(
      DateTimeRange input, DateTimeRange minMax) {
    /// 1. start & end must be in the same day
    if (!input.sameDay()) return left(const ValueFailure.dateRangeNotSameDay());

    /// 2. must be in range
    if (input.inRange(minMax)) {
      return left(
          ValueFailure.dateOutRange(min: minMax.start, max: minMax.end));
    }

    /// everything is ok
    return right(input);
  }
}

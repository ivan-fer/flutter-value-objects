import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'value_failure.freezed.dart';

@freezed
sealed class ValueFailure with _$ValueFailure {
  /// general -----------------------------------------------------
  const factory ValueFailure.invalid({
    /// string name of the object with failure
    @Default('') String nameObject,
  }) = Invalid;
  const factory ValueFailure.invalidFormat({
    /// string name of the object with failure
    @Default('') String nameObject,
    @Default('') String message,
  }) = InvalidFormat;

  const factory ValueFailure.enumNone({
    /// string name of the object with failure
    @Default('') String nameObject,
  }) = EnumNone;

  /// String -----------------------------------------------------
  const factory ValueFailure.strEmpty({
    /// string name of the object with failure
    @Default('') String nameObject,
  }) = StrEmpty;

  const factory ValueFailure.strMaxLength({
    /// string name of the object with failure
    @Default('') String nameObject,

    /// the max characters allow in the string
    required int maxAllow,

    /// length of the input string
    required int total,
  }) = StrMaxLength;

  const factory ValueFailure.strMinLength({
    /// string name of the object with failure
    @Default('') String nameObject,

    /// the min characters allow in the string
    required int minAllow,

    /// length of the input string
    required int total,
  }) = StrMinLength;

  const factory ValueFailure.strMultiline({
    /// string name of the object with failure
    @Default('') String nameObject,
  }) = StrMultiline;

  /// numbers ----------------------------------------------------
  const factory ValueFailure.notANumber({
    /// string name of the object with failure
    @Default('') String nameObject,
  }) = NotANumber;
  const factory ValueFailure.numOutRange({
    /// string name of the object with failure
    @Default('') String nameObject,
    required num min,
    required num max,
  }) = NumOutRange;

  /// dates & times ----------------------------------------------
  const factory ValueFailure.dateOutRange({
    /// string name of the object with failure
    @Default('') String nameObject,
    required DateTime min,
    required DateTime max,
  }) = DateOutRange;
  const factory ValueFailure.timeOutRange({
    /// string name of the object with failure
    @Default('') String nameObject,
    required TimeOfDay min,
    required TimeOfDay max,
  }) = TimeOutRange;

  /// the date range is not in the same day
  const factory ValueFailure.dateRangeNotSameDay({
    /// string name of the object with failure
    @Default('') String nameObject,
  }) = DateRangeNotSameDay;

  const factory ValueFailure.durationInvalid({
    /// string name of the object with failure
    @Default('') String nameObject,
  }) = DurationInvalid;

  const factory ValueFailure.durationOutRange({
    /// string name of the object with failure
    @Default('') String nameObject,
    required Duration min,
    required Duration max,
  }) = DurationOutRange;
}

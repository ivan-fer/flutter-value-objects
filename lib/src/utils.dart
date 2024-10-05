import 'package:flutter/material.dart';

/// utils for [DateTimeRange]
extension DateTimeRangeX on DateTimeRange {
  /// check if two ranges overlap
  bool overlap(DateTimeRange other) =>
      start.isBefore(other.end) && end.isAfter(other.start) ? true : false;

  /// range occurs on the same day
  bool sameDay() =>
      start.year == end.year &&
      start.month == end.month &&
      start.day == end.day;

  /// if this range is include in other
  bool inRange(DateTimeRange other) => start.isAfter(other.start) &&
          start.isAtSameMomentAs(other.start) &&
          end.isAfter(other.end) &&
          end.isAtSameMomentAs(other.end)
      ? true
      : false;
}

extension DateTimeX on DateTime {
  String toDayName() => switch (day) {
        (DateTime.monday) => 'Monday',
        (DateTime.tuesday) => 'Tuesday',
        (DateTime.wednesday) => 'Wednesday',
        (DateTime.thursday) => 'Thursday',
        (DateTime.friday) => 'Friday',
        (DateTime.saturday) => 'Saturday',
        (DateTime.sunday) => 'Sunday',
        (_) => '',
      };

  String toDayNameSpanish() => switch (day) {
        (DateTime.monday) => 'Lunes',
        (DateTime.tuesday) => 'Martes',
        (DateTime.wednesday) => 'Miércoles',
        (DateTime.thursday) => 'Jueves',
        (DateTime.friday) => 'Viernes',
        (DateTime.saturday) => 'Sábado',
        (DateTime.sunday) => 'Domingo',
        (_) => '',
      };

  String toMonthName() {
    return '';
  }

  String toMonthNameSpanish() {
    return '';
  }
}

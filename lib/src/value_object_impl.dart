import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import 'value_failure.dart';
import 'value_object.dart';
import 'value_text.dart';

class UniqueId extends ValueObject<String> {
  @override
  final Either<ValueFailure, String> value;

  factory UniqueId() => UniqueId._(right(const Uuid().v4()));

  factory UniqueId.fromUniqueString(String uniqueId) =>
      UniqueId._(right(uniqueId));

  const UniqueId._(this.value);

  @override
  String? validate() => null;
}

class ValueName extends ValueObject<String> {
  @override
  final Either<ValueFailure, String> value;

  final String? Function(ValueName)? onValidate;

  factory ValueName(
    String input, {
    String? Function(ValueName)? fnValidate,
    int maxLength = 65,
  }) {
    return ValueName._(validator(input, maxLength), fnValidate);
  }

  const ValueName._(this.value, this.onValidate);

  @override
  String? validate() => onValidate != null
      ? onValidate!(this)
      : value.fold(
          (f) => f.maybeMap(
            strEmpty: (_) => 'Debes ingresar un nombre',
            strMaxLength: (s) =>
                'El nombre es muy largo, debe ser hasta ${s.maxAllow} caracteres',
            strMultiline: (_) => 'El nombre debe estar en una sola línea',
            invalid: (_) =>
                'El nombre no puede tener caracteres especiales (como <>?+, etc.)',
            orElse: () => null,
          ),
          (_) => null,
        );

  static Either<ValueFailure, String> validator(String input, int max) {
    input = input.trim();
    return validatorStringIsEmpty(input)
        .flatMap((a) => validatorStringExceedMaxLength(a, max))
        .flatMap(validatorStringIsMultiline)
        .flatMap(validateTextSimpleFormat);
  }
}

class ValueEmail extends ValueObject<String> {
  @override
  final Either<ValueFailure, String> value;

  final String? Function(ValueEmail)? onValidate;

  factory ValueEmail(String input, {String? Function(ValueEmail)? fnValidate}) {
    return ValueEmail._(validator(input), fnValidate);
  }

  const ValueEmail._(this.value, this.onValidate);

  @override
  String? validate() => onValidate != null
      ? onValidate!(this)
      : value.fold(
          (f) => f.maybeMap(
            strEmpty: (_) => 'Debes ingresar un correo',
            invalid: (_) =>
                'El correo no tiene el formato correcto (ejemplo@dominio.com)',
            orElse: () => null,
          ),
          (_) => null,
        );

  static Either<ValueFailure, String> validator(String input) {
    input = input.trim();
    return validatorStringIsEmpty(input).flatMap(
      (a) {
        const email =
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
        if (!RegExp(email).hasMatch(a)) {
          return left(const ValueFailure.invalid());
        }
        return right(a);
      },
    );
  }
}

class ValuePhone extends ValueObject<String> {
  @override
  final Either<ValueFailure, String> value;

  final String? Function(ValuePhone)? onValidate;

  factory ValuePhone(String input, {String? Function(ValuePhone)? fnValidate}) {
    return ValuePhone._(validator(input, 8, 9), fnValidate);
  }

  const ValuePhone._(this.value, this.onValidate);

  @override
  String? validate() => onValidate != null
      ? onValidate!(this)
      : value.fold(
          (f) => f.maybeMap(
            strEmpty: (_) => 'Debes ingresar un teléfono o celular',
            strMaxLength: (_) => 'El teléfono debe tener 9 números como máximo',
            strMinLength: (_) => 'El teléfono debe tener 8 números como mínimo',
            invalid: (_) => 'El teléfono no tiene el formato correcto',
            orElse: () => null,
          ),
          (_) => null,
        );

  static Either<ValueFailure, String> validator(
      String input, int min, int max) {
    input = input.trim();
    return validatorStringIsEmpty(input)
        .flatMap((a) => validatorStringExceedMinLength(a, min))
        .flatMap((a) => validatorStringExceedMaxLength(a, max))
        .flatMap(
      (a) {
        const phone = r'(0[0-9]{8})|((2|4)[0-9]{7})';
        if (!RegExp(phone).hasMatch(a)) {
          return left(ValueFailure.invalid(nameObject: a));
        }
        return right(a);
      },
    );
  }
}

class ValuePassword extends ValueObject<String> {
  @override
  final Either<ValueFailure, String> value;

  factory ValuePassword(String input, {int min = 8, int max = 16}) {
    return ValuePassword._(validator(input, min, max));
  }

  const ValuePassword._(this.value);

  @override
  String? validate() => value.fold(
        (f) => f.maybeMap(
          strEmpty: (_) => 'La contraseña no puede estar vacía',
          strMinLength: (_) =>
              'La contraseña debe ser de al menos 8 caracteres',
          strMaxLength: (_) => 'La contraseña debe ser máximo 16 caracteres',
          invalid: (_) =>
              'La contraseña debe tener por lo menos una letra mayúscula, una minúscula y un número',
          orElse: () => null,
        ),
        (_) => null,
      );

  static Either<ValueFailure, String> validator(
      String input, int min, int max) {
    input = input.trim();
    return validatorStringIsEmpty(input)
        .flatMap((a) => validatorStringExceedMinLength(a, min))
        .flatMap((a) => validatorStringExceedMaxLength(a, max))
        .flatMap(
      (a) {
        const phone = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{1,}$';
        if (!RegExp(phone).hasMatch(a)) {
          return left(ValueFailure.invalid(nameObject: a));
        }
        return right(a);
      },
    );
  }
}

/// Manage an integer that must be in a range
class ValueNumber extends ValueObject<int> {
  @override
  final Either<ValueFailure, int> value;

  factory ValueNumber(String input, {int min = 0, int max = 100}) {
    return ValueNumber._(validator(input.trim(), min, max));
  }

  const ValueNumber._(this.value);

  @override
  String? validate() => value.fold(
        (f) => f.maybeMap(
          strEmpty: (_) => 'Must enter a number',
          notANumber: (_) => 'Value is not a number',
          numOutRange: (s) =>
              'Value is out of range, min: ${s.min} max: ${s.max}',
          orElse: () => null,
        ),
        (_) => null,
      );

  static Either<ValueFailure, int> validator(String input, int min, int max) {
    if (input.isEmpty) {
      return left(const ValueFailure.strEmpty());
    }
    final i = int.tryParse(input);
    if (i == null) {
      return left(const ValueFailure.notANumber());
    }
    if (i < min || i > max) {
      return left(ValueFailure.numOutRange(min: min, max: max));
    }
    return right(i);
  }
}

/// Manage an optional integer. If exist, act like [ValueNumber]
class ValueOptionNumber extends ValueObject<Option<String>> {
  @override
  final Either<ValueFailure, Option<String>> value;

  factory ValueOptionNumber(Option<String> input,
      {int min = 0, int max = 100}) {
    return ValueOptionNumber._(input.fold(
      () => right(none()),
      (a) {
        final v = ValueNumber(a, min: min, max: max);
        return v.value.fold(
          (f) => left(f),
          (r) => right(some('$r')),
        );
      },
    ));
  }

  const ValueOptionNumber._(this.value);

  @override
  String? validate() => value.fold(
        (f) => f.maybeMap(
          strEmpty: (_) => 'Value cannot be empty',
          notANumber: (_) => 'Value is not a number',
          numOutRange: (s) =>
              'Value is out of range, min: ${s.min} max: ${s.max}',
          orElse: () => null,
        ),
        (_) => null,
      );
}

/// Manage a double that must be in a range
class ValueDouble extends ValueObject<double> {
  @override
  final Either<ValueFailure, double> value;

  factory ValueDouble(String input, {int min = 0, int max = 100}) {
    return ValueDouble._(validator(input.trim(), min, max));
  }

  const ValueDouble._(this.value);

  @override
  String? validate() => value.fold(
        (f) => f.maybeMap(
          strEmpty: (_) => 'Must enter a number',
          notANumber: (_) => 'Value is not a number',
          numOutRange: (s) =>
              'Value is out of range, min: ${s.min} max: ${s.max}',
          orElse: () => null,
        ),
        (_) => null,
      );

  static Either<ValueFailure, double> validator(
      String input, int min, int max) {
    if (input.isEmpty) {
      return left(const ValueFailure.strEmpty());
    }
    final i = double.tryParse(input);
    if (i == null) {
      return left(const ValueFailure.notANumber());
    }
    if (i < min || i > max) {
      return left(ValueFailure.numOutRange(min: min, max: max));
    }
    return right(i);
  }
}

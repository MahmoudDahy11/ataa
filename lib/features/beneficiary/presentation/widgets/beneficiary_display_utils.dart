import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';

String formatEnumLabel(String value) {
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}

String maskNationalId(String nationalId) {
  if (nationalId.length < 4) {
    return nationalId;
  }
  return '${nationalId.substring(0, 2)}********${nationalId.substring(nationalId.length - 4)}';
}

String maskPhone(String phone) {
  if (phone.length < 4) {
    return phone;
  }
  return '${phone.substring(0, phone.length - 4)}****';
}

String maskPayoutValue(String value) {
  if (value.length < 4) {
    return value;
  }
  return '${value.substring(0, 2)}****${value.substring(value.length - 2)}';
}

int? calculateAge(DateTime? dateOfBirth) {
  if (dateOfBirth == null) {
    return null;
  }
  final now = DateTime.now();
  var age = now.year - dateOfBirth.year;
  if (now.month < dateOfBirth.month ||
      (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
    age--;
  }
  return age;
}

String documentLabel(String type) {
  return RequiredDocumentType.labels[type] ?? formatEnumLabel(type);
}

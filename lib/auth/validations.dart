import '../templates/mainTemplates.dart';

bool validateNotEmpty(String text) {
  if (text.length > 0) return true;
  return false;
}

bool validateMaxLength(String text, int maxLength) {
  if (text.length <= maxLength) return true;
  return false;
}

bool validateCivilID(String text) {
  if (text.length == 12) return true;
  return false;
}

bool validateEmail(String text) {
  RegExp regex = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  if (regex.hasMatch(text)) return true;
  return false;
}

bool validatePassword(String text) {
  RegExp regex =
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
  if (regex.hasMatch(text)) return true;
  return false;
}

bool validateOnlyString(String text) {
  RegExp regex = RegExp(r'^[a-zA-Z\u0621-\u064A ]+$');
  if (regex.hasMatch(text)) return true;
  return false;
}

bool validatePhone(String text) {
  RegExp regex = RegExp(r'^(?!0+$)[0-9\u0660-\u0669]{8,15}$');
  if (regex.hasMatch(text)) return true;
  return false;
}

bool validatePin(String text) {
  RegExp regex = RegExp(r'^[0-9\u0660-\u0669]{4,8}$');
  if (regex.hasMatch(text)) return true;
  return false;
}

String validateRegEx(String text, List<ValidatorTemplate> validations) {
  if (validations.length == 0) return 'S';
  for (int v = 0; v < validations.length; v++) {
    RegExp regex = RegExp(validations[v].regex);
    if (!regex.hasMatch(text)) return validations[v].message;
  }
  return 'S';
}

bool validateArabicNumber(String text) {
  RegExp regex = RegExp(r'^[\u0621-\u064A\u0660-\u0669 ]+$');
  if (regex.hasMatch(text)) return false;
  return true;
}

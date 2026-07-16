class Validators {
  static bool isNotEmpty(String? value) => value != null && value.trim().isNotEmpty;

  static bool isPositiveNumber(int? value) => value != null && value > 0;

  static bool isInRange(int value, int min, int max) => value >= min && value <= max;

  static bool isEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  static bool isPhoneNumber(String phone) {
    final regex = RegExp(r'^\+?[0-9]{10,15}$');
    return regex.hasMatch(phone);
  }

  static bool isFreeTextAnswerValid(String? answer, int minLength) {
    if (answer == null || answer.trim().isEmpty) return false;
    return answer.trim().length >= minLength;
  }
}
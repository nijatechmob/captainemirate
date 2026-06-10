


class AuthValidation {
  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full Name is required';
    } else if (value.length < 2) {
      return 'Full Name should be at least 2 characters long';
    } else if (value.length > 50) {
      return 'Full Name should not exceed 50 characters';
    }
    return null;
  }

  String? validateMobileNo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile is required';
    } else if (value.length != 10) {
      return 'Mobile number should be 10 digits';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    } else if (value.length < 4) {
      return 'Password must be at least 4 characters';
    } else if (value.length > 15) {
      return 'Please enter valid password';
    } else if (!containsLetter(value) || !containsNumber(value)) {
      return 'Password must contain letters and numbers';
    }
    return null;
  }

  String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  bool containsLetter(String value) =>
      RegExp(r'[a-zA-Z]').hasMatch(value);

  bool containsNumber(String value) =>
      RegExp(r'[0-9]').hasMatch(value);
}
class ValidatorForm {
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Không được để trống';
    } else if (value.length < 6) {
      return 'Độ dài ít nhất 6 ký tự';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    } else if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%\^&\*])')
        .hasMatch(value)) {
      return 'Mật khẩu phải có chữ thường, chữ hoa, số và kí tự đặc biệt';
    }
    return null;
  }

  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Không được để trống';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || !RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? validateDob(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ngày sinh không được bỏ trống';
    }
    return null;
  }

  bool validatePhoneBool(String? value) {
    if (value != null &&
        value.isNotEmpty &&
        !RegExp(r'^\d{10}$').hasMatch(value)) {
      return false;
    }
    return true;
  }

  bool validateEmailBool(String? value) {
    if (value != null &&
        value.isNotEmpty &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return false;
    }
    return true;
  }
}

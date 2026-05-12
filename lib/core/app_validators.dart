
class AppValidators {
  AppValidators._();

 static String? emailOrPhoneValidator(String? value) {

    if (value == null || value.trim().isEmpty) {
      return "Required";
    }
    value = value.trim();
    bool isEmail = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(value);
    bool isPhone = RegExp(
      r'^(010|011|012|015)\d{8}$',
    ).hasMatch(value);
    if (!isEmail && !isPhone) {
      return "Enter valid email or phone";
    }
    return null;
  }
 static String? validepassword(String? val) {
    RegExp passwordRegex = RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])');

    if (val!.length < 8 || !passwordRegex.hasMatch(val)) {
      return 'strong password please';
    }
    return null;
  }

 static  String? validecpassword(String? val,String? password) {
    if (val == null || val.isEmpty) {
      return 'Password is not confirmed';
    }

    if (val != password) {
      return 'Passwords do not match';
    }



    return null;
  }
  static String? validateChangePassword(String? val) {
    if (val == null || val.isEmpty) {
      return null;
    }

    RegExp passwordRegex = RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])');

    if (val.length < 8 || !passwordRegex.hasMatch(val)) {
      return 'strong password please';
    }

    return null;
  }
  static String? validateConfirmChangePassword(String? val, String? password) {
    if ((password == null || password.isEmpty) &&
        (val == null || val.isEmpty)) {
      return null;
    }

    if (val != password) {
      return 'Passwords do not match';
    }

    return null;
  }
  static String? validateUsername(String? val) {
    RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9,.-]+$');
    if (val == null) {
      return 'this field is required';
    } else if (val.isEmpty) {
      return 'this field is required';
    } else if (!usernameRegex.hasMatch(val)) {
      return 'enter valid username';
    } else {
      return null;
    }
  }
  static String? validateFullName(String? val) {
    if (val == null || val.isEmpty) {
      return 'this field is required';
    } else {
      return null;
    }
  }


  static String? validatePhoneNumber(String? val) {
    if (val == null) {
      return 'this field is required';
    } else if (int.tryParse(val.trim()) == null) {
      return 'enter numbers only';
    } else if (val.trim().length != 11) {
      return 'enter value must equal 11 digit';
    } else {
      return null;
    }
  }




}

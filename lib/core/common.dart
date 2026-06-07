class Validate {
  static final RegExp emailExp = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
  );

  static final RegExp hostAddressExp = RegExp(r"^http[s]{0,1}://.+$");

  static String? username(String? username) {
    if (username == null || username.isEmpty) {
      return "Invalid username";
    }
    return null;
  }

  static String? password(String? password) {
    if (password == null || password.isEmpty) {
      return "Invalid password";
    }
    return null;
  }

  static String? email(String? email) {
    if (email == null || email.isEmpty || !emailExp.hasMatch(email)) {
      return "Invalid email";
    }

    return null;
  }

  static String? path(String? path) {
    if (path == null || path.isEmpty) {
      return "Invalid path";
    }
    return null;
  }

  static String? serverAddress(String? address, {String? invalidText}) {
    if (address == null || address.trim().isEmpty) {
      return invalidText ?? "Address cannot be empty";
    }

    final urlPattern = RegExp(
      r'^https?://'
      r'(([a-zA-Z0-9\-_]+\.)+[a-zA-Z]{2,}|'
      r'localhost|'
      r'(\d{1,3}\.){3}\d{1,3})'
      r'(:\d+)?'
      r'(/.*)?$',
    );

    if (!urlPattern.hasMatch(address.trim())) {
      return invalidText ?? "Invalid address";
    }

    return null;
  }
}

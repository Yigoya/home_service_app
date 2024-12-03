class AppException implements Exception {
  final String message;
  final String prefix;

  AppException([this.message = "Something went wrong", this.prefix = ""]);

  @override
  String toString() {
    return "$prefix$message";
  }
}

class NetworkException extends AppException {
  NetworkException([String message = "Network issue occurred."])
      : super(message, "Network Error: ");
}

class ServerException extends AppException {
  ServerException([String message = "Server error occurred."])
      : super(message, "Server Error: ");
}

class ValidationException extends AppException {
  ValidationException([String message = "Invalid input."])
      : super(message, "Validation Error: ");
}

class UnknownException extends AppException {
  UnknownException([String message = "An unknown error occurred."])
      : super(message, "Error: ");
}

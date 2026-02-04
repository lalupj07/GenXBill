import 'dart:developer' as developer;

class AppLogger {
  static void info(String message) {
    developer.log(message, name: 'GenXBill', level: 0);
  }

  static void warning(String message) {
    developer.log(message, name: 'GenXBill', level: 900);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: 'GenXBill',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

// core/utils/logger.dart
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    level: Level.debug,
  );

  static void debug(String message) => _logger.d(message);
  static void info(String message) => _logger.i(message);
  static void warning(String message) => _logger.w(message);
  
  static void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (stackTrace != null) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    } else {
      _logger.e(message, error: error);
    }
  }
  
  static void trace(String message) => _logger.t(message);
  static void verbose(String message) => _logger.v(message);
  static void wtf(String message) => _logger.wtf(message);
}
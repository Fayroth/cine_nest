import 'package:flutter/foundation.dart';

enum LogLevel { verbose, debug, info, warning, error }

class Logger {
  static final Logger _instance = Logger._internal();
  factory Logger() => _instance;
  Logger._internal();

  static LogLevel _logLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  static void setLogLevel(LogLevel level) {
    _logLevel = level;
  }

  void v(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.verbose, message, error, stackTrace);
  }

  void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  void _log(LogLevel level, String message, [dynamic error, StackTrace? stackTrace]) {
    if (level.index < _logLevel.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelString = level.toString().split('.').last.toUpperCase();
    final logMessage = '[$timestamp] [$levelString] $message';

    if (kDebugMode) {
      switch (level) {
        case LogLevel.verbose:
        case LogLevel.debug:
        case LogLevel.info:
          debugPrint('💬 $logMessage');
          break;
        case LogLevel.warning:
          debugPrint('⚠️ $logMessage');
          break;
        case LogLevel.error:
          debugPrint('❌ $logMessage');
          if (error != null) {
            debugPrint('Error: $error');
          }
          if (stackTrace != null) {
            debugPrint('StackTrace: $stackTrace');
          }
          break;
      }
    }
  }
}
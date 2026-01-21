import 'dart:developer' as developer;
import 'logger.dart';

class LoggerImpl implements Logger {
  const LoggerImpl();

  void _log(String level, String message, int logLevel, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: level, level: logLevel, error: error, stackTrace: stackTrace);
  }

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _log('DEBUG', message, 800, error, stackTrace);
  }

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _log('INFO', message, 700, error, stackTrace);
  }

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log('WARNING', message, 900, error, stackTrace);
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, 1000, error, stackTrace);
  }
}

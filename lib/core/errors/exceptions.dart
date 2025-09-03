// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

// Server exceptions
class ServerException extends AppException {
  const ServerException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);
}

// Network exceptions
class NetworkException extends AppException {
  const NetworkException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);
}

// Cache exceptions
class CacheException extends AppException {
  const CacheException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);
}

// API exceptions
class ApiException extends AppException {
  final int? statusCode;

  const ApiException({
    required String message,
    this.statusCode,
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);
}

// Auth exceptions
class AuthException extends AppException {
  const AuthException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);
}

// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String>? errors;

  const ValidationException({
    required String message,
    this.errors,
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);
}

// Parse exceptions
class ParseException extends AppException {
  const ParseException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);
}

// Rate limit exception
class RateLimitException extends AppException {
  final DateTime? retryAfter;

  const RateLimitException({
    required String message,
    this.retryAfter,
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);
}
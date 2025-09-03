import 'package:equatable/equatable.dart';

// Base failure class
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

// Server failure
class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

// Cache failure
class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

// Invalid input failure
class InvalidInputFailure extends Failure {
  const InvalidInputFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

// Auth failure
class AuthFailure extends Failure {
  const AuthFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure({
    String message = 'An unexpected error occurred',
    String? code,
  }) : super(message: message, code: code);
}

// Helper extension to convert exceptions to failures
extension FailureMapper on Exception {
  Failure toFailure() {
    // You can expand this based on your exception types
    if (this is NetworkFailure) {
      return NetworkFailure(message: toString());
    } else if (this is ServerFailure) {
      return ServerFailure(message: toString());
    } else {
      return UnknownFailure(message: toString());
    }
  }
}
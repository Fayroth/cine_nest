import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../utils/logger.dart';

class ApiClient {
  late final Dio _dio;
  final Logger _logger = Logger();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          ...ApiConstants.headers,
          // Use Bearer token for authentication (recommended by TMDB)
          'Authorization': 'Bearer ${dotenv.env['TMDB_API_READ_ACCESS_TOKEN'] ?? ''}',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      request: true,
      responseBody: true,
      error: true,
      requestBody: true,
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('REQUEST[${options.method}] => PATH: ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          handler.next(error);
        },
      ),
    );
  }

  // GET request
  Future<T> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onReceiveProgress,
      }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return _handleResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<T> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return _handleResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<T> put<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return _handleResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<T> delete<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Handle successful response
  T _handleResponse<T>(Response<T> response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data as T;
    } else {
      throw ApiException(
        message: 'Request failed with status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  // Handle errors
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkException(
            message: 'Connection timeout. Please check your internet connection.',
            code: 'TIMEOUT',
          );

        case DioExceptionType.connectionError:
          return const NetworkException(
            message: 'No internet connection. Please check your network.',
            code: 'NO_INTERNET',
          );

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;

          String message = 'Request failed';
          if (data != null && data is Map && data.containsKey('status_message')) {
            message = data['status_message'];
          }

          switch (statusCode) {
            case 400:
              return ApiException(
                message: message,
                statusCode: statusCode,
                code: 'BAD_REQUEST',
              );
            case 401:
              return AuthException(
                message: 'Unauthorized. Please check your API key.',
                code: 'UNAUTHORIZED',
              );
            case 404:
              return ApiException(
                message: 'Resource not found',
                statusCode: statusCode,
                code: 'NOT_FOUND',
              );
            case 429:
              return RateLimitException(
                message: 'Too many requests. Please try again later.',
                code: 'RATE_LIMITED',
              );
            case 500:
            case 502:
            case 503:
              return ServerException(
                message: 'Server error. Please try again later.',
                code: 'SERVER_ERROR',
              );
            default:
              return ApiException(
                message: message,
                statusCode: statusCode,
              );
          }

        case DioExceptionType.cancel:
          return const ApiException(
            message: 'Request cancelled',
            code: 'CANCELLED',
          );

        default:
          return ApiException(
            message: error.message ?? 'Unknown error occurred',
            originalError: error,
          );
      }
    } else if (error is SocketException) {
      return const NetworkException(
        message: 'No internet connection',
        code: 'NO_INTERNET',
      );
    } else {
      return ApiException(
        message: error.toString(),
        originalError: error,
      );
    }
  }
}
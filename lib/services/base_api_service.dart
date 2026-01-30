import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Base API Service that handles all HTTP communications
/// Automatically attaches Firebase authentication token to requests
/// and handles token refresh
class BaseApiService {
  late final Dio _dio;
  final String baseUrl;

  BaseApiService({
    required this.baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout ?? const Duration(seconds: 30),
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptor to automatically attach Firebase token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get Firebase token and attach to request
          final token = await _getFirebaseToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized - token might be expired
          if (error.response?.statusCode == 401) {
            try {
              // Try to refresh token and retry request
              final token = await _getFirebaseToken(forceRefresh: true);
              if (token != null) {
                // Retry the request with new token
                final opts = error.requestOptions;
                opts.headers['Authorization'] = 'Bearer $token';

                final cloneReq = await _dio.request(
                  opts.path,
                  options: Options(method: opts.method, headers: opts.headers),
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                );

                return handler.resolve(cloneReq);
              }
            } catch (e) {
              // If refresh fails, return original error
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Get Firebase authentication token
  /// [forceRefresh] - If true, forces token refresh even if current token is valid
  Future<String?> _getFirebaseToken({bool forceRefresh = false}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('Firebase token: null (no user)');
        return null;
      }

      // getIdToken automatically refreshes the token if it's expired
      // If forceRefresh is true, it will always get a fresh token
      final token = await user.getIdToken(forceRefresh);
      debugPrint('Firebase token: $token');
      return token;
    } catch (e) {
      debugPrint('Error getting Firebase token: $e');
      return null;
    }
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Handle errors
  void _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          debugPrint('Request timeout: ${error.message}');
          break;
        case DioExceptionType.badResponse:
          debugPrint(
            'Bad response: ${error.response?.statusCode} - ${error.response?.data}',
          );
          break;
        case DioExceptionType.cancel:
          debugPrint('Request cancelled');
          break;
        case DioExceptionType.unknown:
          debugPrint('Unknown error: ${error.message}');
          break;
        default:
          debugPrint('Error: ${error.message}');
      }
    } else {
      debugPrint('Unexpected error: $error');
    }
  }

  /// Get the underlying Dio instance (for advanced usage)
  Dio get dio => _dio;
}

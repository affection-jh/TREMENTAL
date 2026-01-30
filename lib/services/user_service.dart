import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tremental/services/base_api_service.dart';
import 'package:tremental/config/api_config.dart';

/// User Service for tremental server
/// Singleton pattern for global access
class UserService {
  static UserService? _instance;
  late final BaseApiService _api;
  Map<String, dynamic>? _cachedUser;

  UserService._internal() {
    _api = BaseApiService(baseUrl: ApiConfig.baseUrl);
  }

  factory UserService() {
    _instance ??= UserService._internal();
    return _instance!;
  }

  /// Get current user information (synchronous - from cache)
  /// 동기적으로 캐시된 유저 정보 반환
  Map<String, dynamic>? get currentUser => _cachedUser;

  /// Get current user information (async - from server)
  /// GET /api/users
  /// 없으면 토큰 기준으로 생성 후 반환
  /// 캐시도 자동으로 업데이트됨
  /// throws: DioException (타임아웃 등)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _api.get<Map<String, dynamic>>('/api/users');
      _cachedUser = response.data;
      return _cachedUser;
    } on DioException catch (e) {
      // 타임아웃은 다시 throw
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        _cachedUser = null;
        rethrow;
      }
      // 401이면 토큰 문제 (BaseApiService에서 자동 처리)
      debugPrint('Error getting current user: $e');
      _cachedUser = null;
      return null;
    } catch (e) {
      // 기타 에러
      debugPrint('Error getting current user: $e');
      _cachedUser = null;
      return null;
    }
  }

  /// Load and cache user information
  /// 로그인 후 자동으로 호출되어야 함
  /// throws: DioException (타임아웃 등)
  Future<void> loadUser() async {
    try {
      await getCurrentUser();
    } catch (e) {
      // 타임아웃은 다시 throw
      if (e is DioException &&
          (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout)) {
        rethrow;
      }
      // 다른 에러는 무시 (캐시가 있으면 사용)
    }
  }

  /// Clear cached user information
  /// 로그아웃 시 호출
  void clearCache() {
    _cachedUser = null;
  }

  /// Register/Sync user
  /// POST /api/users
  /// 토큰 기준으로 유저 생성(이미 있으면 email/name/picture 갱신)
  Future<Map<String, dynamic>?> registerUser({
    required String uid,
    required String? email,
    required String? displayName,
    required String? photoUrl,
    required String provider, // 'google' or 'apple'
  }) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/api/users',
        data: {
          // 서버에서 토큰으로 uid를 알아내므로 body에 uid는 필요 없을 수 있음
          // 하지만 명세에 명시되지 않았으므로 일단 포함
          'email': email,
          'name': displayName,
          'picture': photoUrl,
        },
      );
      // 캐시 업데이트
      _cachedUser = response.data;
      return _cachedUser;
    } catch (e) {
      debugPrint('Error registering user: $e');
      rethrow;
    }
  }

  /// Update user information (partial update)
  /// PATCH /api/users
  /// 수정할 필드만 본문에 포함
  Future<Map<String, dynamic>?> updateUser({
    String? name,
    String? email,
    String? picture,
    bool? needOnboarding,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (picture != null) data['picture'] = picture;
      if (needOnboarding != null) data['needOnboarding'] = needOnboarding;

      if (data.isEmpty) {
        throw Exception('No fields to update');
      }

      final response = await _api.patch<Map<String, dynamic>>(
        '/api/users',
        data: data,
      );
      // 캐시 업데이트
      _cachedUser = response.data;
      return _cachedUser;
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  /// Delete user
  /// DELETE /api/users
  /// 현재 유저 및 연관 데이터 삭제
  Future<void> deleteUser() async {
    try {
      await _api.delete('/api/users');
      // 캐시 클리어
      _cachedUser = null;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }
}

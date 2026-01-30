import 'dart:async';
import 'package:dio/dio.dart';
import 'package:tremental/services/user_service.dart';

/// 앱 초기화 및 데이터 로드를 담당하는 서비스
class InitializationService {
  final UserService _userService = UserService();

  /// 초기 데이터 로드
  /// 실제 구현 시 여기에 필요한 데이터 로드 로직을 추가
  /// throws: DioException (타임아웃 등)
  Future<void> loadInitialData() async {
    try {
      // 유저 정보 로드
      await _userService.loadUser();
    } on DioException catch (e) {
      // 타임아웃 에러는 다시 throw
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        rethrow;
      }
      // 다른 에러는 무시하고 계속 진행
    }

    // 플레이스홀더: 실제 데이터 로드 로직으로 대체
    await Future.delayed(const Duration(milliseconds: 500));

    // 예시: 여기에 실제 데이터 로드 로직 추가
    // await _loadUserData();
    // await _loadAppSettings();
    // await _loadCache();
  }

  /// 최소 스플래시 표시 시간 (2초)
  Future<void> showMinimumSplash() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  /// 전체 초기화 프로세스
  /// 데이터 로드와 최소 스플래시 시간을 병렬로 처리
  /// 반환값: needOnboarding 여부 (null이면 타임아웃 에러)
  /// throws: DioException (타임아웃 등)
  Future<bool?> initialize() async {
    try {
      await Future.wait([loadInitialData(), showMinimumSplash()]);

      // needOnboarding 판단
      final serverUser = _userService.currentUser;
      final needOnboarding = serverUser?['needOnboarding'] == true;

      return needOnboarding;
    } on DioException catch (e) {
      // 타임아웃 에러 체크
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        rethrow; // 타임아웃은 다시 throw하여 SplashScreen에서 처리
      }
      rethrow;
    }
  }
}

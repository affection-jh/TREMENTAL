import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:tremental/theme/app_colors.dart';
import 'package:tremental/widgets/poo.dart';
import 'package:tremental/services/initialization_service.dart';
import 'package:tremental/services/auth_service.dart';
import 'package:tremental/screens/main_screen.dart';
import 'package:tremental/screens/login_screen.dart';
import 'package:tremental/screens/onboarding_flow.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final InitializationService _initService = InitializationService();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // InitializationService에서 모든 초기화 및 판단 수행
      final needOnboarding = await _initService.initialize();

      if (!mounted) return;

      // needOnboarding에 따라 적절한 화면으로 이동
      if (needOnboarding == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingFlow()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } on DioException catch (e) {
      // 타임아웃 에러 처리
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        if (!mounted) return;

        // 로그아웃 처리
        final authService = AuthService();
        await authService.signOut();

        // 로그인 화면으로 이동 및 스낵바 표시
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('연결 오류가 발생했습니다. 다시 시도해주세요')),
          );
        }
      }
    } catch (e) {
      // 기타 에러 처리
      if (!mounted) return;

      // 로그아웃 처리
      final authService = AuthService();
      await authService.signOut();

      // 로그인 화면으로 이동 및 스낵바 표시
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('초기화 중 오류가 발생했습니다: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 북극곰 이미지
              const Poo(pose: PooPose.sitting, width: 200, height: 200),
              const SizedBox(height: 40),
              // 로딩 인디케이터
              const CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

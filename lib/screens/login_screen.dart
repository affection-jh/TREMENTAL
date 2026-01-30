import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tremental/theme/app_colors.dart';
import 'package:tremental/theme/app_text_styles.dart';
import 'package:tremental/services/auth_service.dart';
import 'package:tremental/screens/privacy_policy_screen.dart';
import 'package:tremental/screens/splash_screen.dart';
import 'package:tremental/widgets/poo.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final List<String> _exampleWords = [
    '트리멘탈',
    '오늘 기분은 어때?',
    '무엇이 궁금하신가요?',
    '감정을 기록해보세요',
  ];
  int _currentWordIndex = 0;
  String _displayText = '';
  int _charIndex = 0;
  bool _isDeleting = false;
  Timer? _timer;
  late AnimationController _cursorController;
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _startTypingAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorController.dispose();
    super.dispose();
  }

  void _startTypingAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) return;

      setState(() {
        final currentWord = _exampleWords[_currentWordIndex];

        if (!_isDeleting) {
          if (_charIndex < currentWord.length) {
            _displayText = currentWord.substring(0, _charIndex + 1);
            _charIndex++;
          } else {
            // Wait before starting to delete
            Future.delayed(const Duration(milliseconds: 2000), () {
              if (mounted) {
                setState(() {
                  _isDeleting = true;
                });
              }
            });
          }
        } else {
          if (_displayText.isNotEmpty) {
            _displayText = _displayText.substring(0, _displayText.length - 1);
          } else {
            // Move to next word
            _isDeleting = false;
            _charIndex = 0;
            _currentWordIndex = (_currentWordIndex + 1) % _exampleWords.length;
          }
        }
      });
    });
  }

  Future<void> _handleAppleSignIn() async {
    if (_isSigningIn) return;

    setState(() {
      _isSigningIn = true;
    });

    try {
      final authService = AuthService();
      final userCredential = await authService.signInWithApple();

      // 사용자가 취소한 경우 (null 반환)는 조용히 처리 - 스낵바 없이
      if (userCredential == null) {
        if (mounted) {
          setState(() {
            _isSigningIn = false;
          });
        }
        return;
      }

      // 로그인 성공 - AuthWrapper가 자동으로 SplashScreen으로 이동
      // SplashScreen에서 needOnboarding 판단 및 네비게이션 처리
    } on SignInWithAppleAuthorizationException catch (e) {
      // 사용자가 취소한 경우는 조용히 처리 (스낵바 없이)
      if (e.code == AuthorizationErrorCode.canceled) {
        if (mounted) {
          setState(() {
            _isSigningIn = false;
          });
        }
        return;
      }

      // Apple Sign-In 특정 에러 처리
      if (mounted) {
        String errorMessage = 'Apple 로그인 중 오류가 발생했습니다.';

        if (e.code == AuthorizationErrorCode.unknown) {
          errorMessage = 'Apple 로그인을 사용할 수 없습니다. 설정을 확인해주세요.';
        } else if (e.code == AuthorizationErrorCode.invalidResponse) {
          errorMessage = 'Apple 로그인 응답이 올바르지 않습니다.';
        } else if (e.code == AuthorizationErrorCode.notHandled) {
          errorMessage = 'Apple 로그인을 처리할 수 없습니다.';
        } else if (e.code == AuthorizationErrorCode.failed) {
          errorMessage = 'Apple 로그인에 실패했습니다.';
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('로그인 중 오류가 발생했습니다: $e')));
      }
    } finally {
      if (mounted && !_isSigningIn) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isSigningIn) return;

    setState(() {
      _isSigningIn = true;
    });

    try {
      final authService = AuthService();
      final userCredential = await authService.signInWithGoogle();

      // 사용자가 취소한 경우 (null 반환)는 조용히 처리 - 스낵바 없이
      if (userCredential == null) {
        if (mounted) {
          setState(() {
            _isSigningIn = false;
          });
        }
        return;
      }

      // 로그인 성공 - SplashScreen으로 이동
      // SplashScreen에서 InitializationService를 통해 needOnboarding 판단 및 네비게이션 처리
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('로그인 중 오류가 발생했습니다: $e')));
      }
    }
  }

  void _navigateToPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Title text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: '어디서나,',
                          style: AppTextStyles.notoSansKr(
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '감정을 ',
                              style: AppTextStyles.notoSansKr(
                                fontSize: 28,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary.withOpacity(0.5),
                              ),
                            ),
                            TextSpan(
                              text: '체계적으로',
                              style: AppTextStyles.notoSansKr(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Polar bear image - dynamically sized to fit screen
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final availableWidth =
                        screenWidth - 48; // horizontal padding
                    final availableHeight = constraints.maxHeight;

                    // Use the smaller dimension to ensure it fits without overflow
                    final maxSize =
                        (availableWidth < availableHeight)
                            ? availableWidth
                            : availableHeight;

                    // Use maximum available size
                    final imageSize = maxSize.clamp(250.0, double.infinity);

                    return Center(
                      child: Poo(
                        pose: PooPose.sitting,
                        width: imageSize * 2,
                        height: imageSize * 2,
                      ),
                    );
                  },
                ),
              ),

              // Input field with typing animation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  _displayText,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                AnimatedBuilder(
                                  animation: _cursorController,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _cursorController.value,
                                      child: Container(
                                        width: 2,
                                        height: 20,
                                        margin: const EdgeInsets.only(left: 2),
                                        color: AppColors.primary,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.send,
                            color: AppColors.textSecondary.withOpacity(0.5),
                            size: 20,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),
                    // 로그인 중이면 로딩 스피너, 아니면 버튼들
                    if (_isSigningIn)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          // Apple Sign In Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _handleAppleSignIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.cardColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/apple_logo.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'APPLE로 시작하기',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Google Sign In Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _handleGoogleSignIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.textPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: AppColors.textSecondary.withOpacity(
                                      0.1,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/google_logo.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Google로 시작하기',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 30),
                    // Privacy Policy Link
                    GestureDetector(
                      onTap: _navigateToPrivacyPolicy,
                      child: Text(
                        '개인정보 처리방침 및 이용약관',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withOpacity(0.6),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

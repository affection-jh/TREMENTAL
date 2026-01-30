import 'package:flutter/material.dart';
import 'package:tremental/theme/app_colors.dart';
import 'package:tremental/theme/app_text_styles.dart';
import 'package:tremental/widgets/poo.dart';
import 'package:tremental/services/user_service.dart';
import 'package:tremental/screens/main_screen.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final TextEditingController _nicknameController = TextEditingController();
  final UserService _userService = UserService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submitNickname() async {
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('별명을 입력해주세요')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 서버에 별명 업데이트 및 온보딩 완료 플래그 설정
      await _userService.updateUser(
        name: _nicknameController.text.trim(),
        needOnboarding: false,
      );
      // updateUser가 자동으로 캐시를 업데이트함

      if (mounted) {
        // 온보딩 완료 - 메인 화면으로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Poo 이미지
              const Poo(pose: PooPose.sitting, width: 120, height: 120),
              const SizedBox(height: 48),
              // 안내 텍스트
              Text(
                '별명을 입력해주세요',
                style: AppTextStyles.notoSansKr(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '트리멘탈에서 사용할 별명을 설정해주세요',
                style: AppTextStyles.notoSansKr(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // 별명 입력 필드
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  hintText: '별명을 입력하세요',
                  hintStyle: AppTextStyles.notoSansKr(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: AppTextStyles.notoSansKr(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submitNickname(),
              ),
              const SizedBox(height: 32),
              // 완료 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitNickname,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text(
                            '완료',
                            style: AppTextStyles.notoSansKr(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

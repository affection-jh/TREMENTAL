import 'package:flutter/material.dart';
import 'package:tremental/theme/app_colors.dart';
import 'package:tremental/theme/app_text_styles.dart';
import 'package:tremental/services/user_service.dart';
import 'package:tremental/widgets/band_card.dart';
import 'package:tremental/widgets/goto_chat_card.dart';
import 'package:tremental/widgets/poo.dart';
import 'package:tremental/widgets/conversation_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: WelcomeText(subtitle: '오늘은 평온해보여요!'),
            ),

            const Poo(pose: PooPose.standing, width: 350, height: 350),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: BandCard(title: 'Hun의 밴드', percentage: 72.0)),
                  const SizedBox(width: 4),

                  Expanded(
                    child: GoToChatCard(
                      title: '바로 아무거나',
                      subtitle: '곰돌이랑 대화 시작하기',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '대화가 필요해요',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      3,
                      (index) => Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ConversationCard(
                    date: '2025.12.25',
                    address: '성동구 왕십리로 45',
                    time: '14:15',
                    record: '12:34',
                  ),
                  const SizedBox(height: 4),
                  ConversationCard(
                    date: '2025.12.23',
                    address: '성동구 왕십리로 45',
                    time: '14:15',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class WelcomeText extends StatefulWidget {
  const WelcomeText({super.key, required this.subtitle});

  final String subtitle;

  @override
  State<WelcomeText> createState() => _WelcomeTextState();
}

class _WelcomeTextState extends State<WelcomeText> {
  final UserService _userService = UserService();
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 캐시에서 동기적으로 읽기
    final user = _userService.currentUser;
    if (user != null) {
      _userName = user['name'] as String?;
      _isLoading = false;
    } else {
      // 캐시에 없으면 서버에서 로드
      _loadUserName();
    }
  }

  Future<void> _loadUserName() async {
    try {
      await _userService.loadUser();
      if (mounted) {
        setState(() {
          _userName = _userService.currentUser?['name'] as String?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isLoading
              ? '안녕하세요,'
              : _userName != null && _userName!.isNotEmpty
              ? '안녕하세요, $_userName님'
              : '안녕하세요,',
          style: AppTextStyles.notoSansKr(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          widget.subtitle,
          style: AppTextStyles.notoSansKr(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

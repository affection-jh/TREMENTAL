import 'package:flutter/material.dart';
import 'package:tremental/theme/app_colors.dart';
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
            const SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: WelcomeText(title: '안녕하세요,', subtitle: '오늘은 평온해보여요!'),
            ),

            const Poo(pose: PooPose.standing, width: 400, height: 400),

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
            const SizedBox(height: 32),
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

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.displayLarge),
        Text(subtitle, style: Theme.of(context).textTheme.headlineLarge),
      ],
    );
  }
}

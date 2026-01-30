import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 곰돌이 대화 시작 카드
class GoToChatCard extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;
  final String subtitle;

  const GoToChatCard({
    super.key,
    this.title = '바로 아무거나',
    this.subtitle = '곰돌이랑 대화 시작하기',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width * 0.98;

        return Container(
          padding: const EdgeInsets.all(16),
          height: height,
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Spacer(),
              Text(
                '곰돌이랑',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '대화 시작하기',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

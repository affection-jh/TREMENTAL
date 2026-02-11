import 'package:flutter/material.dart';
import 'package:tremental/chat/chat_styles.dart';
import 'package:tremental/theme/app_colors.dart';
import 'package:tremental/theme/app_text_styles.dart';

class ChatIntroHeader extends StatelessWidget {
  const ChatIntroHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.notoSansKr(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

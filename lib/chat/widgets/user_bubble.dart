import 'package:flutter/material.dart';
import 'package:tremental/chat/chat_styles.dart';
import 'package:tremental/theme/app_colors.dart';

class UserBubble extends StatelessWidget {
  const UserBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(text, style: ChatStyles.userBubbleText(context)),
        ),
      ),
    );
  }
}

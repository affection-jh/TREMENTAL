import 'package:flutter/material.dart';
import 'package:tremental/chat/chat_styles.dart';

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
        Text(title, style: ChatStyles.botTitle(context)),
        const SizedBox(height: 6),
        Text(subtitle, style: ChatStyles.botSubtitle(context)),
      ],
    );
  }
}

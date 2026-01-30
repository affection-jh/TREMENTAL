import 'package:flutter/material.dart';
import 'package:tremental/theme/app_colors.dart';

class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText = '메시지를 입력하세요',
    this.enabled = true,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final String hintText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFE6E6E6))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.45),
                    fontSize: 14.5,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF3F3F3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: enabled ? (_) => onSend() : null,
              ),
            ),
            const SizedBox(width: 10),
            _SendButton(onTap: enabled ? onSend : null),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFFEFF1FF) : const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Icon(
            Icons.send_rounded,
            size: 18,
            color:
                isEnabled
                    ? AppColors.primary
                    : AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}

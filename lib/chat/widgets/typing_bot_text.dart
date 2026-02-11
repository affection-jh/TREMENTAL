import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tremental/chat/bot_text.dart';

/// 타이핑 애니메이션이 있는 봇 텍스트 위젯
/// 한 줄씩 부드럽게 나타나는 효과
class TypingBotText extends StatefulWidget {
  const TypingBotText({
    super.key,
    required this.text,
    this.onComplete,
    this.onTyping,
  });

  final String text;
  final VoidCallback? onComplete;
  final VoidCallback? onTyping;

  @override
  State<TypingBotText> createState() => _TypingBotTextState();
}

class _TypingBotTextState extends State<TypingBotText> {
  String _displayedText = '';
  int _currentIndex = 0;
  Timer? _timer;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    _startTyping();
    _startScrollTimer();
  }

  void _startTyping() {
    // 각 문자를 표시하는 속도 (밀리초) - 더 빠르게
    const typingSpeed = 25;

    _timer = Timer.periodic(const Duration(milliseconds: typingSpeed), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText = widget.text.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
      } else {
        timer.cancel();
        _scrollTimer?.cancel();
        widget.onComplete?.call();
      }
    });
  }

  /// 타이핑 중 스크롤을 자동으로 따라가도록
  void _startScrollTimer() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted || _currentIndex >= widget.text.length) {
        timer.cancel();
        return;
      }
      widget.onTyping?.call();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: BotText(_displayedText),
      ),
    );
  }
}

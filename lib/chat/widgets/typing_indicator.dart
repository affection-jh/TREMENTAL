import 'package:flutter/material.dart';
import 'package:tremental/chat/chat_styles.dart';

/// 봇이 입력 중일 때 표시하는 점 세 개 애니메이션
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    // 세 개의 점에 각각 다른 딜레이를 주어 순차적으로 애니메이션
    _dotAnimations = List.generate(
      3,
      (index) => TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 0.3,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1.0,
        ),
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1.0,
            end: 0.3,
          ).chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1.0,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.15,
            0.7 + index * 0.15,
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _dotAnimations[index],
          builder: (context, child) {
            return Opacity(
              opacity: _dotAnimations[index].value,
              child: Padding(
                padding: EdgeInsets.only(right: index < 2 ? 4.0 : 0.0),
                child: Text(
                  '•',
                  style: ChatStyles.botBody(
                    context,
                  ).copyWith(fontSize: 20, height: 1.0),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

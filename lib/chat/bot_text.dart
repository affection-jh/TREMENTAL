import 'package:flutter/material.dart';
import 'package:tremental/chat/chat_styles.dart';

/// 챗봇 말풍선 없이 "바닥에 뿌리는 텍스트"용 공통 위젯.
///
/// - `**bold**` 마커를 파싱해서 볼드/일반을 섞어 렌더링합니다.
/// - 예) `혹시 **이 일과 관련이 있나요?**`
class BotText extends StatelessWidget {
  const BotText(
    this.text, {
    super.key,
    this.maxLines,
    this.textAlign = TextAlign.start,
    this.normalStyle,
    this.boldStyle,
  });

  final String text;
  final int? maxLines;
  final TextAlign textAlign;
  final TextStyle? normalStyle;
  final TextStyle? boldStyle;

  @override
  Widget build(BuildContext context) {
    final spans = _parseBoldMarkdown(
      text,
      normal: normalStyle ?? ChatStyles.botBody(context),
      bold: boldStyle ?? ChatStyles.botBodyBold(context),
    );

    return RichText(
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines == null ? TextOverflow.visible : TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }
}

List<TextSpan> _parseBoldMarkdown(
  String input, {
  required TextStyle normal,
  required TextStyle bold,
}) {
  final spans = <TextSpan>[];
  final buffer = StringBuffer();
  var isBold = false;

  void flush() {
    if (buffer.isEmpty) return;
    spans.add(TextSpan(text: buffer.toString(), style: isBold ? bold : normal));
    buffer.clear();
  }

  for (var i = 0; i < input.length; i++) {
    final ch = input[i];
    final next = i + 1 < input.length ? input[i + 1] : null;

    if (ch == '*' && next == '*') {
      flush();
      isBold = !isBold;
      i++; // skip next '*'
      continue;
    }
    buffer.write(ch);
  }

  flush();

  // 마커가 짝이 안 맞는 경우에도 안전하게(그냥 토글된 상태로 출력) 끝냅니다.
  return spans;
}

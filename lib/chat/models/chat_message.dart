/// 채팅 메시지 타입
enum ChatMessageType {
  /// 사용자가 보낸 메시지
  user,

  /// 챗봇이 보낸 메시지 (텍스트 블록)
  bot,
}

/// 채팅 메시지 모델
class ChatMessage {
  const ChatMessage({
    required this.type,
    required this.content,
    this.timestamp,
  });

  final ChatMessageType type;
  final String content;
  final DateTime? timestamp;

  /// 사용자 메시지 생성
  factory ChatMessage.user(String content) {
    return ChatMessage(
      type: ChatMessageType.user,
      content: content,
      timestamp: DateTime.now(),
    );
  }

  /// 봇 메시지 생성
  factory ChatMessage.bot(String content) {
    return ChatMessage(
      type: ChatMessageType.bot,
      content: content,
      timestamp: DateTime.now(),
    );
  }
}

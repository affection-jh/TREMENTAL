/// 대화 데이터 모델
class Conversation {
  final String id;
  final DateTime date;
  final String? address;
  final String? topic;
  final Duration? duration;
  final ConversationType type;

  Conversation({
    required this.id,
    required this.date,
    this.address,
    this.topic,
    this.duration,
    required this.type,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      address: json['address'] as String?,
      topic: json['topic'] as String?,
      duration:
          json['duration'] != null
              ? Duration(seconds: json['duration'] as int)
              : null,
      type: ConversationTypeExtension.fromString(json['type'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'address': address,
      'topic': topic,
      'duration': duration?.inSeconds,
      'type': type.toJsonString(),
    };
  }
}

/// 대화 타입
enum ConversationType {
  scheduled, // 예정된 대화
  completed, // 완료된 대화
}

extension ConversationTypeExtension on ConversationType {
  static ConversationType fromString(String value) {
    switch (value) {
      case 'scheduled':
        return ConversationType.scheduled;
      case 'completed':
        return ConversationType.completed;
      default:
        return ConversationType.completed;
    }
  }

  String toJsonString() {
    switch (this) {
      case ConversationType.scheduled:
        return 'scheduled';
      case ConversationType.completed:
        return 'completed';
    }
  }
}

/// 월별 대화 데이터
class MonthlyConversations {
  final int year;
  final int month;
  final List<Conversation> conversations;
  final String? monthlyMessage; // "2월은 대화가 차분하네요!" 같은 메시지

  MonthlyConversations({
    required this.year,
    required this.month,
    required this.conversations,
    this.monthlyMessage,
  });

  factory MonthlyConversations.fromJson(Map<String, dynamic> json) {
    return MonthlyConversations(
      year: json['year'] as int,
      month: json['month'] as int,
      conversations:
          (json['conversations'] as List)
              .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
              .toList(),
      monthlyMessage: json['monthlyMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'conversations': conversations.map((e) => e.toJson()).toList(),
      'monthlyMessage': monthlyMessage,
    };
  }

  /// 특정 날짜의 대화 목록 가져오기
  List<Conversation> getConversationsForDate(DateTime date) {
    return conversations.where((conv) {
      return conv.date.year == date.year &&
          conv.date.month == date.month &&
          conv.date.day == date.day;
    }).toList();
  }

  /// 예정된 대화 목록 가져오기
  List<Conversation> getScheduledConversations() {
    return conversations
        .where((conv) => conv.type == ConversationType.scheduled)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// 완료된 대화 목록 가져오기
  List<Conversation> getCompletedConversations() {
    return conversations
        .where((conv) => conv.type == ConversationType.completed)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}

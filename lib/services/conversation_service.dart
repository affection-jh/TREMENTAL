import 'dart:convert';
import 'package:tremental/models/conversation.dart';

/// 대화 데이터 서비스 (임시 JSON 데이터 사용)
class ConversationService {
  static final ConversationService _instance = ConversationService._internal();
  factory ConversationService() => _instance;
  ConversationService._internal();

  /// 캐시된 월별 데이터
  final Map<String, MonthlyConversations> _cache = {};

  /// 임시 JSON 데이터 생성
  String _generateMockJson(int year, int month) {
    // 2025년 2월 예시 데이터
    if (year == 2025 && month == 2) {
      return '''
      {
        "year": 2025,
        "month": 2,
        "monthlyMessage": "2월은 대화가 차분하네요!",
        "conversations": [
          {
            "id": "1",
            "date": "2025-02-21T14:15:00",
            "address": "성동구 왕십리로 45",
            "type": "scheduled"
          },
          {
            "id": "2",
            "date": "2025-02-25T10:00:00",
            "address": "성동구 왕십리로 45",
            "topic": "크리스마스에 뭐할지에 대한 대화",
            "type": "completed",
            "duration": 754
          },
          {
            "id": "3",
            "date": "2025-02-23T15:30:00",
            "address": "성동구 왕십리로 45",
            "topic": "주말 계획에 대한 대화",
            "type": "completed",
            "duration": 420
          },
          {
            "id": "4",
            "date": "2025-02-01T09:00:00",
            "address": "성동구 왕십리로 45",
            "type": "completed",
            "duration": 600
          },
          {
            "id": "5",
            "date": "2025-02-02T11:00:00",
            "address": "성동구 왕십리로 45",
            "type": "completed",
            "duration": 480
          },
          {
            "id": "6",
            "date": "2025-02-03T13:00:00",
            "address": "성동구 왕십리로 45",
            "type": "completed",
            "duration": 360
          },
          {
            "id": "7",
            "date": "2025-02-04T14:00:00",
            "address": "성동구 왕십리로 45",
            "type": "completed",
            "duration": 540
          },
          {
            "id": "8",
            "date": "2025-02-05T16:00:00",
            "address": "성동구 왕십리로 45",
            "type": "completed",
            "duration": 720
          },
          {
            "id": "9",
            "date": "2025-02-06T10:00:00",
            "address": "성동구 왕십리로 45",
            "type": "completed",
            "duration": 300
          },
          {
            "id": "10",
            "date": "2025-02-07T12:00:00",
            "address": "성동구 왕십리로 45",
            "type": "completed",
            "duration": 450
          },
          {
            "id": "11",
            "date": "2025-02-08T15:00:00",
            "address": "성동구 왕십리로 45",
            "type": "completed",
            "duration": 600
          },
          {
            "id": "12",
            "date": "2025-02-09T09:30:00",
            "address": "성동구 왕십리로 45",
            "type": "completed",
            "duration": 480
          },
          {
            "id": "13",
            "date": "2025-02-10T11:30:00",
            "address": "성동구 왕십리로 45",
            "type": "completed",
            "duration": 360
          },
          {
            "id": "14",
            "date": "2025-02-11T13:30:00",
            "address": "성동구 왕십리로 45",
            "type": "completed",
            "duration": 540
          },
          {
            "id": "15",
            "date": "2025-02-13T14:30:00",
            "address": "성동구 왕십리로 45",
            "type": "completed",
            "duration": 420
          },
          {
            "id": "16",
            "date": "2025-02-14T16:00:00",
            "address": "성동구 왕십리로 45",
            "type": "completed",
            "duration": 600
          },
          {
            "id": "17",
            "date": "2025-02-16T10:00:00",
            "address": "성동구 왕십리로 45",
            "type": "completed",
            "duration": 480
          },
          {
            "id": "18",
            "date": "2025-02-17T12:00:00",
            "address": "성동구 왕십리로 45",
            "type": "completed",
            "duration": 360
          },
          {
            "id": "19",
            "date": "2025-02-18T15:00:00",
            "address": "성동구 왕십리로 45",
            "type": "completed",
            "duration": 720
          },
          {
            "id": "20",
            "date": "2025-02-19T09:00:00",
            "address": "성동구 왕십리로 45",
            "type": "completed",
            "duration": 300
          },
          {
            "id": "21",
            "date": "2025-02-20T11:00:00",
            "address": "성동구 왕십리로 45",
            "type": "completed",
            "duration": 450
          }
        ]
      }
      ''';
    }

    // 다른 월은 빈 데이터 반환
    return '''
    {
      "year": $year,
      "month": $month,
      "monthlyMessage": null,
      "conversations": []
    }
    ''';
  }

  /// 특정 월의 대화 데이터 가져오기
  Future<MonthlyConversations> getMonthlyConversations(
    int year,
    int month,
  ) async {
    final cacheKey = '$year-$month';

    // 캐시에 있으면 반환
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // 임시: 네트워크 요청 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));

    // JSON 데이터 파싱
    final jsonString = _generateMockJson(year, month);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final monthlyData = MonthlyConversations.fromJson(json);

    // 캐시에 저장
    _cache[cacheKey] = monthlyData;

    return monthlyData;
  }

  /// 특정 날짜의 대화 목록 가져오기
  Future<List<Conversation>> getConversationsForDate(DateTime date) async {
    final monthlyData = await getMonthlyConversations(date.year, date.month);
    return monthlyData.getConversationsForDate(date);
  }

  /// 캐시 초기화
  void clearCache() {
    _cache.clear();
  }
}

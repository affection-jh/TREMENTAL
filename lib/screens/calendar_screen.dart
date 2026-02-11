import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tremental/theme/app_colors.dart';
import 'package:tremental/theme/app_text_styles.dart';
import 'package:tremental/models/conversation.dart';
import 'package:tremental/services/conversation_service.dart';
import 'package:tremental/widgets/poo.dart';
import 'package:tremental/widgets/conversation_card.dart';
import 'package:tremental/screens/chat_screen.dart';
import 'package:tremental/providers/overlay_provider.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ConversationService _conversationService = ConversationService();
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  Map<String, MonthlyConversations> _loadedMonths = {};

  @override
  void initState() {
    super.initState();
    _loadMonth(_currentMonth.year, _currentMonth.month);
  }

  Future<void> _loadMonth(int year, int month) async {
    final key = '$year-$month';
    if (_loadedMonths.containsKey(key)) return;

    try {
      final monthlyData = await _conversationService.getMonthlyConversations(
        year,
        month,
      );
      setState(() {
        _loadedMonths[key] = monthlyData;
      });
    } catch (e) {
      // 에러 처리
    }
  }

  MonthlyConversations? _getCurrentMonthData() {
    final key = '${_currentMonth.year}-${_currentMonth.month}';
    return _loadedMonths[key];
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadMonth(_currentMonth.year, _currentMonth.month);
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _loadMonth(_currentMonth.year, _currentMonth.month);
  }

  @override
  Widget build(BuildContext context) {
    final monthData = _getCurrentMonthData();
    final selectedDateConversations =
        monthData
            ?.getConversationsForDate(_selectedDate)
            .where((c) => c.type == ConversationType.scheduled)
            .toList() ??
        [];
    final pastConversations =
        monthData
            ?.getCompletedConversations()
            .where(
              (c) =>
                  c.date.year == _selectedDate.year &&
                  c.date.month == _selectedDate.month &&
                  c.date.day == _selectedDate.day,
            )
            .toList() ??
        [];

    // 하드코딩된 샘플 데이터 (임시)
    final hardcodedScheduledConversations =
        selectedDateConversations.isEmpty
            ? [
              Conversation(
                id: 'hardcoded-1',
                date: DateTime(2025, 12, 25, 14, 15),
                type: ConversationType.scheduled,
                address: '성동구 왕십리로 45',
              ),
            ]
            : selectedDateConversations;

    final hardcodedPastConversations =
        pastConversations.isEmpty
            ? [
              Conversation(
                id: 'hardcoded-past-1',
                date: DateTime(2025, 12, 25),
                type: ConversationType.completed,
                topic: '크리스마스에 뭐할지에 대한 대화',
              ),
              Conversation(
                id: 'hardcoded-past-2',
                date: DateTime(2025, 12, 25),
                type: ConversationType.completed,
                topic: '크리스마스에 뭐할지에 대한 대화',
              ),
            ]
            : pastConversations;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),
            // 년도 선택
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: () {
                  final overlayProvider = context.read<OverlayProvider>();
                  overlayProvider.show(
                    _DatePickerContent(
                      currentYear: _currentMonth.year,
                      currentMonth: _currentMonth.month,
                      onCancel: () {
                        context.read<OverlayProvider>().hide();
                      },
                      onConfirm: (year, month) {
                        setState(() {
                          _currentMonth = DateTime(year, month);
                        });
                        _loadMonth(year, month);
                        context.read<OverlayProvider>().hide();
                      },
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${_currentMonth.year}',
                      style: AppTextStyles.notoSansKr(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 북극곰과 월별 메시지
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                height: 100,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 20),
                          onPressed: _previousMonth,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(width: 120), // 곰 공간 확보
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              monthData?.monthlyMessage ??
                                  '${_currentMonth.month}월',
                              style: AppTextStyles.notoSansKr(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 20),
                          onPressed: _nextMonth,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                      ],
                    ),
                    // 곰이 위로 삐져나오도록
                    Positioned(
                      left: 48,
                      top: -45,
                      child: const Poo(
                        pose: PooPose.sitting,
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 달력
            _buildCalendar(monthData),
            const SizedBox(height: 32),
            // 대화가 필요해요 섹션
            ConversationSectionHeader(
              dayOfWeek: _getDayOfWeek(_selectedDate),
              day: _selectedDate.day,
              title: '대화가 필요해요',
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildScheduledConversationCard(
                hardcodedScheduledConversations.first,
              ),
            ),
            const SizedBox(height: 32),
            // 지난 대화 둘러보기
            ConversationSectionHeader(
              dayOfWeek: _getDayOfWeek(_selectedDate),
              day: _selectedDate.day,
              title: '지난 대화 둘러보기',
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children:
                    hardcodedPastConversations
                        .map((conv) => _buildPastConversationCard(conv))
                        .toList(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(MonthlyConversations? monthData) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstDayWeekday = firstDay.weekday;
    final daysInMonth = lastDay.day;

    // 이전 달의 마지막 날들
    final prevMonthLastDay = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      0,
    );
    final prevMonthDays = prevMonthLastDay.day;

    // 날짜별 대화 개수
    final conversationCounts = <int, int>{};
    if (monthData != null) {
      for (var conv in monthData.conversations) {
        final day = conv.date.day;
        conversationCounts[day] = (conversationCounts[day] ?? 0) + 1;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 요일 헤더
          Row(
            children:
                ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                    .map(
                      (day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: AppTextStyles.notoSansKr(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 16),
          // 달력 그리드
          ...List.generate(((firstDayWeekday - 1) + daysInMonth + 6) ~/ 7, (
            weekIndex,
          ) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(7, (dayIndex) {
                final dayOfWeek =
                    weekIndex * 7 + dayIndex - (firstDayWeekday - 1) + 1;

                // 이전 달 날짜
                if (dayOfWeek < 1) {
                  final prevDay =
                      prevMonthDays - (firstDayWeekday - 1 - dayIndex);
                  return Expanded(
                    child: Container(
                      height: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            '$prevDay',
                            style: AppTextStyles.notoSansKr(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary.withOpacity(0.3),
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(height: 13),
                        ],
                      ),
                    ),
                  );
                }

                // 다음 달 날짜
                if (dayOfWeek > daysInMonth) {
                  final nextDay = dayOfWeek - daysInMonth;
                  return Expanded(
                    child: Container(
                      height: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            '$nextDay',
                            style: AppTextStyles.notoSansKr(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary.withOpacity(0.3),
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(height: 13),
                        ],
                      ),
                    ),
                  );
                }

                final isSelected =
                    _selectedDate.year == _currentMonth.year &&
                    _selectedDate.month == _currentMonth.month &&
                    _selectedDate.day == dayOfWeek;
                final currentDate = DateTime(
                  _currentMonth.year,
                  _currentMonth.month,
                  dayOfWeek,
                );
                final today = DateTime.now();
                final isToday =
                    currentDate.year == today.year &&
                    currentDate.month == today.month &&
                    currentDate.day == today.day;
                final hasConversation = conversationCounts.containsKey(
                  dayOfWeek,
                );
                final conversationCount = conversationCounts[dayOfWeek] ?? 0;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = DateTime(
                          _currentMonth.year,
                          _currentMonth.month,
                          dayOfWeek,
                        );
                      });
                    },
                    child: Container(
                      height: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.cardColor
                                : Colors.transparent,
                        border:
                            isToday && !isSelected
                                ? Border.all(
                                  color: AppColors.primary,
                                  width: 1.5,
                                )
                                : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            '$dayOfWeek',
                            style: AppTextStyles.notoSansKr(
                              fontSize: 16,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          if (hasConversation)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  conversationCount.clamp(0, 3),
                                  (_) => Container(
                                    width: 5,
                                    height: 5,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 13),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScheduledConversationCard(Conversation conversation) {
    final timeFormat = DateFormat('HH:mm');
    final dateStr = DateFormat('yyyy.MM.dd').format(conversation.date);
    final timeStr = timeFormat.format(conversation.date);

    return ConversationCard(
      date: dateStr,
      address: conversation.address,
      time: timeStr,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ChatScreen(
                  conversationAddress: conversation.address,
                  conversationTime: timeStr,
                  conversationDate: dateStr,
                ),
          ),
        );
      },
    );
  }

  Widget _buildPastConversationCard(Conversation conversation) {
    return ConversationCard(
      date: DateFormat('yyyy.MM.dd').format(conversation.date),
      topic: conversation.topic,
      mode: ConversationCardMode.past,
    );
  }

  String _getDayOfWeek(DateTime date) {
    final days = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return days[date.weekday - 1];
  }
}

class _DatePickerContent extends StatefulWidget {
  final int currentYear;
  final int currentMonth;
  final VoidCallback onCancel;
  final void Function(int year, int month) onConfirm;

  const _DatePickerContent({
    required this.currentYear,
    required this.currentMonth,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  State<_DatePickerContent> createState() => _DatePickerContentState();
}

class _DatePickerContentState extends State<_DatePickerContent> {
  late int _tempSelectedYear;
  late int _tempSelectedMonth;
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;

  @override
  void initState() {
    super.initState();
    _tempSelectedYear = widget.currentYear;
    _tempSelectedMonth = widget.currentMonth;

    // 년도 리스트 생성 (2025년부터 현재 년도까지)
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    final startYear = 2025;
    final years = List.generate(
      currentYear - startYear + 1,
      (i) => startYear + i,
    );
    final yearIndex = years.indexOf(widget.currentYear);
    _yearController = FixedExtentScrollController(
      initialItem: yearIndex >= 0 ? yearIndex : 0,
    );

    // 월 리스트 생성 (현재 년도면 현재 월까지만)
    final availableMonths =
        widget.currentYear == currentYear
            ? List.generate(currentMonth, (i) => i + 1)
            : List.generate(12, (i) => i + 1);

    // 현재 월이 사용 가능한 월 범위를 벗어나면 조정
    final adjustedMonth =
        widget.currentMonth > availableMonths.length
            ? availableMonths.length
            : widget.currentMonth;
    final monthIndex = availableMonths.indexOf(adjustedMonth);
    _monthController = FixedExtentScrollController(
      initialItem: monthIndex >= 0 ? monthIndex : 0,
    );

    // 초기 선택 월도 조정
    if (widget.currentYear == currentYear &&
        _tempSelectedMonth > currentMonth) {
      _tempSelectedMonth = currentMonth;
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 년도 리스트 생성 (2025년부터 현재 년도까지)
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    final startYear = 2025;
    final years = List.generate(
      currentYear - startYear + 1,
      (i) => startYear + i,
    );

    // 선택된 년도에 따라 사용 가능한 월 결정
    final availableMonths =
        _tempSelectedYear == currentYear
            ? List.generate(currentMonth, (i) => i + 1)
            : List.generate(12, (i) => i + 1);

    final monthNames = [
      '1월',
      '2월',
      '3월',
      '4월',
      '5월',
      '6월',
      '7월',
      '8월',
      '9월',
      '10월',
      '11월',
      '12월',
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.onCardPrimary),
          onPressed: widget.onCancel,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () {
                widget.onConfirm(_tempSelectedYear, _tempSelectedMonth);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                '적용',
                style: AppTextStyles.notoSansKr(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onCardPrimary,
                ),
              ),
            ),
          ),
        ],
        centerTitle: false,
      ),
      body: Center(
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 년도 Picker
                SizedBox(
                  width: 200,
                  height: 500,
                  child: ClipRect(
                    clipBehavior: Clip.hardEdge,
                    child: CupertinoPicker(
                      scrollController: _yearController,
                      itemExtent: 100,
                      diameterRatio: 1.0,
                      useMagnifier: false,
                      selectionOverlay: Container(),
                      offAxisFraction: 0.0,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _tempSelectedYear = years[index];
                          // 년도 변경 시, 현재 년도이고 선택된 월이 현재 월보다 크면 현재 월로 조정
                          if (_tempSelectedYear == currentYear &&
                              _tempSelectedMonth > currentMonth) {
                            _tempSelectedMonth = currentMonth;
                            // 월 Picker의 아이템 수가 변경되므로 컨트롤러 재설정
                            final newAvailableMonths = List.generate(
                              currentMonth,
                              (i) => i + 1,
                            );
                            final newMonthIndex = newAvailableMonths.indexOf(
                              _tempSelectedMonth,
                            );
                            if (newMonthIndex >= 0) {
                              _monthController.jumpToItem(newMonthIndex);
                            }
                          } else if (_tempSelectedYear < currentYear) {
                            // 과거 년도로 변경 시, 월이 12보다 크면 12로 조정
                            if (_tempSelectedMonth > 12) {
                              _tempSelectedMonth = 12;
                              _monthController.jumpToItem(11);
                            }
                          }
                        });
                      },
                      children:
                          years.map((year) {
                            return Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Text(
                                  '$year',
                                  style: AppTextStyles.notoSansKr(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.onCardPrimary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
                // 월 Picker
                SizedBox(
                  width: 150,
                  height: 500,
                  child: ClipRect(
                    clipBehavior: Clip.hardEdge,
                    child: CupertinoPicker(
                      scrollController: _monthController,
                      itemExtent: 100,
                      diameterRatio: 1.0,
                      useMagnifier: false,
                      selectionOverlay: Container(),
                      offAxisFraction: 0.0,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _tempSelectedMonth = availableMonths[index];
                        });
                      },
                      children:
                          availableMonths.map((month) {
                            final monthName = monthNames[month - 1];
                            return Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Text(
                                  monthName,
                                  style: AppTextStyles.notoSansKr(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.onCardPrimary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            // 고정된 "년" 텍스트
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  '년',
                  style: AppTextStyles.notoSansKr(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: AppColors.onCardPrimary.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 대화 섹션 헤더 (예: "목요일 21 대화가 필요해요")
class ConversationSectionHeader extends StatelessWidget {
  final String dayOfWeek;
  final int day;
  final String title;

  const ConversationSectionHeader({
    super.key,
    required this.dayOfWeek,
    required this.day,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$dayOfWeek $day',
            style: AppTextStyles.notoSansKr(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: AppColors.textSecondary,
            ),
          ),

          Text(
            title,
            style: AppTextStyles.notoSansKr(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

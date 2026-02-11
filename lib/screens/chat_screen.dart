import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tremental/chat/bot_text.dart';
import 'package:tremental/chat/chat_styles.dart';
import 'package:tremental/chat/models/chat_message.dart';
import 'package:tremental/chat/widgets/chat_composer.dart';
import 'package:tremental/chat/widgets/chat_intro_header.dart';
import 'package:tremental/chat/widgets/chat_top_bar.dart';
import 'package:tremental/chat/widgets/typing_bot_text.dart';
import 'package:tremental/chat/widgets/typing_indicator.dart';
import 'package:tremental/chat/widgets/user_bubble.dart';
import 'package:tremental/theme/app_colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    this.conversationAddress,
    this.conversationTime,
    this.conversationDate,
  });

  final String? conversationAddress;
  final String? conversationTime;
  final String? conversationDate;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <ChatMessage>[];
  double _keyboardInset = 0.0;
  bool _isLoading = false;
  bool _isUserScrolling = false;
  bool _shouldAutoScroll = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(() => setState(() {}));
    _setupScrollListeners();
  }

  void _setupScrollListeners() {
    // 사용자가 실제로 스크롤을 조작 중인지 감지
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      final position = _scrollController.position;
      final maxScrollExtent = position.maxScrollExtent;
      final currentOffset = position.pixels;
      final isAtBottom = (maxScrollExtent - currentOffset) < 50.0;

      // 사용자가 스크롤을 조작 중이면 자동 스크롤 비활성화
      if (position.isScrollingNotifier.value) {
        _isUserScrolling = true;
        _shouldAutoScroll = false;
      } else {
        // 스크롤이 멈췄을 때
        if (isAtBottom) {
          // 맨 아래에 있으면 자동 스크롤 재개
          _isUserScrolling = false;
          _shouldAutoScroll = true;
        } else {
          // 맨 아래가 아니면 자동 스크롤 비활성화 유지
          _shouldAutoScroll = false;
        }
      }
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset =
        WidgetsBinding.instance.window.viewInsets.bottom /
        WidgetsBinding.instance.window.devicePixelRatio;

    final delta = bottomInset - _keyboardInset;

    // 키보드가 올라올 때만 스크롤 보정 (키보드가 내려갈 때는 보정하지 않음)
    if (delta > 0 && _scrollController.hasClients) {
      // 키보드가 올라오면 컴포저가 가려지지 않도록 스크롤 조정
      // 하지만 사용자가 수동으로 스크롤 중이면 보정하지 않음
      if (!_isUserScrolling && _shouldAutoScroll) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && mounted) {
            // 키보드 높이만큼 스크롤을 올려서 마지막 메시지가 보이도록
            final currentOffset = _scrollController.offset;
            final maxScrollExtent = _scrollController.position.maxScrollExtent;
            final newOffset = (currentOffset + delta).clamp(
              0.0,
              maxScrollExtent,
            );

            // 스크롤이 필요할 때만 조정 (이미 맨 아래에 있으면 조정 불필요)
            if (newOffset <= maxScrollExtent) {
              _scrollController.jumpTo(newOffset);
            }
          }
        });
      }
    }

    _keyboardInset = bottomInset;
  }

  /// 사용자 메시지에 따라 긴 AI 응답 생성
  String _generateBotResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    // 감정 관련 키워드
    if (lowerMessage.contains('기분') ||
        lowerMessage.contains('감정') ||
        lowerMessage.contains('느낌') ||
        lowerMessage.contains('마음')) {
      return '그런 감정을 느끼셨군요. 감정은 우리가 경험하는 삶의 중요한 부분이에요. '
          '때로는 복잡하고 혼란스러울 수 있지만, 그 자체로 의미 있는 경험이라고 생각해요. '
          '지금 이 순간의 감정을 있는 그대로 받아들이는 것도 중요하답니다. '
          '혹시 이 감정이 언제부터 시작되었는지, 어떤 상황에서 더 강하게 느껴지는지 생각해보신 적 있나요? '
          '그런 세부사항들을 함께 살펴보면 더 깊이 이해할 수 있을 것 같아요.';
    }

    // 스트레스나 걱정 관련
    if (lowerMessage.contains('걱정') ||
        lowerMessage.contains('스트레스') ||
        lowerMessage.contains('불안') ||
        lowerMessage.contains('우려')) {
      return '걱정이 되시는군요. 걱정은 미래에 대한 불확실성에서 나오는 자연스러운 반응이에요. '
          '하지만 그 걱정이 지금 이 순간을 지배하게 두는 것은 아쉽지 않을까요? '
          '때로는 걱정을 나눔으로써 그 무게가 조금 가벼워질 수 있어요. '
          '지금 걱정하고 계신 것에 대해 더 자세히 이야기해보시겠어요? '
          '함께 그 감정을 탐색해보면 어떤 해결책이나 관점을 찾을 수 있을 것 같아요.';
    }

    // 슬픔이나 우울 관련
    if (lowerMessage.contains('슬프') ||
        lowerMessage.contains('우울') ||
        lowerMessage.contains('힘들') ||
        lowerMessage.contains('아픔')) {
      return '힘든 시간을 보내고 계시는군요. 그런 감정을 느끼는 것 자체가 용기 있는 일이에요. '
          '많은 사람들이 자신의 감정을 마주하기를 두려워하거든요. '
          '지금 이 순간이 영원하지 않다는 것을 기억해주세요. 감정은 흐르는 강물처럼 변해가니까요. '
          '혼자서 모든 것을 감당하려고 하지 마세요. 지금 이 대화도 하나의 시작이에요. '
          '더 구체적으로 어떤 부분이 가장 힘드신지 말씀해주시면, 함께 그 감정을 살펴볼 수 있을 것 같아요.';
    }

    // 일상이나 하루 관련
    if (lowerMessage.contains('오늘') ||
        lowerMessage.contains('하루') ||
        lowerMessage.contains('일상')) {
      return '오늘 하루 어떠셨나요? 하루하루는 작은 선택과 경험들의 연속이에요. '
          '때로는 평범해 보이는 하루 속에서도 의미 있는 순간들이 숨어있을 수 있어요. '
          '오늘 하루 중에서 가장 기억에 남는 순간이나, 특별히 느꼈던 감정이 있다면 '
          '그것도 하나의 이야기가 될 수 있어요. '
          '작은 것부터 천천히 나눠보시는 것도 좋을 것 같아요. 어떤 하루를 보내셨는지 궁금해요.';
    }

    // 관계나 사람 관련
    if (lowerMessage.contains('사람') ||
        lowerMessage.contains('관계') ||
        lowerMessage.contains('친구') ||
        lowerMessage.contains('가족')) {
      return '사람과의 관계는 우리 삶에서 가장 복잡하면서도 소중한 부분이에요. '
          '때로는 관계가 우리에게 힘이 되기도 하고, 때로는 부담이 되기도 하죠. '
          '모든 관계에는 서로 다른 이야기와 감정이 얽혀있어요. '
          '지금 그 관계에서 어떤 감정을 느끼고 계신가요? '
          '그 감정을 있는 그대로 표현해보시는 것도 중요해요. '
          '더 자세히 이야기해주시면 함께 그 관계를 이해해볼 수 있을 것 같아요.';
    }

    // 기본 응답 (일반적인 대화)
    return '말씀해주셔서 고마워요. 당신의 이야기를 듣고 싶어요. '
        '때로는 말로 표현하는 것만으로도 마음이 조금 가벼워질 수 있어요. '
        '지금 느끼고 계신 감정이나 생각을 자유롭게 나눠주세요. '
        '판단하지 않고 있는 그대로 듣겠어요. '
        '더 구체적으로 어떤 부분이 궁금하시거나 이야기하고 싶으신가요? '
        '작은 것부터 천천히 나눠보시는 것도 좋을 것 같아요.';
  }

  /// 정적 봇 메시지 (타이핑 애니메이션 없는 완성된 메시지)
  Widget _buildStaticBotMessage(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: BotText(text),
      ),
    );
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage.user(text));
      _controller.clear();
      _isLoading = true; // 로딩 시작
    });

    // 스크롤을 맨 아래로
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // 2초 후 봇 응답 추가 (긴 AI 응답 생성)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false; // 로딩 종료
          final botResponse = _generateBotResponse(text);
          _messages.add(ChatMessage.bot(botResponse));
        });

        // 타이핑 시작 시 스크롤을 맨 아래로
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.trim().isNotEmpty;
    // MediaQuery로 키보드 인셋 가져오기 (더 정확함)
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ChatTopBar(
        time: widget.conversationTime ?? '14:15',
        address: widget.conversationAddress ?? '성동구 왕십리로 45',
      ),
      // Scaffold 기본 리사이즈에 의존하지 않고(플랫폼별 차이), 우리가 인셋으로 정확히 밀어올립니다.
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  // 사용자가 직접 스크롤을 시작했는지 감지
                  if (notification is ScrollStartNotification) {
                    // 사용자가 스크롤을 시작하면 자동 스크롤 비활성화
                    _isUserScrolling = true;
                    _shouldAutoScroll = false;
                  } else if (notification is ScrollEndNotification) {
                    // 스크롤이 끝났을 때 맨 아래인지 확인
                    if (_scrollController.hasClients) {
                      final position = _scrollController.position;
                      final maxScrollExtent = position.maxScrollExtent;
                      final currentOffset = position.pixels;
                      final isAtBottom =
                          (maxScrollExtent - currentOffset) < 50.0;

                      if (isAtBottom) {
                        // 맨 아래에 있으면 자동 스크롤 재개
                        _isUserScrolling = false;
                        _shouldAutoScroll = true;
                      }
                    }
                  }
                  return false;
                },
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    left: ChatStyles.pagePadding.left,
                    right: ChatStyles.pagePadding.right,
                    bottom: 10,
                  ),
                  children: [
                    const ChatIntroHeader(
                      title: '안녕하세요, 왜 놀랐나요?',
                      subtitle: '모든 대화는 암호화되어 보관돼요 안심하고 대화하세요',
                    ),
                    const SizedBox(height: 18),
                    // 동적으로 추가된 메시지들
                    ..._messages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final msg = entry.value;
                      if (msg.type == ChatMessageType.user) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: UserBubble(text: msg.content),
                        );
                      } else {
                        // 마지막 봇 메시지이고 로딩이 끝났으면 타이핑 애니메이션 사용
                        final isLastBotMessage =
                            index == _messages.length - 1 &&
                            msg.type == ChatMessageType.bot &&
                            !_isLoading;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child:
                              isLastBotMessage
                                  ? TypingBotText(
                                    text: msg.content,
                                    onTyping: () {
                                      // 자동 스크롤이 활성화되어 있고 사용자가 스크롤 중이 아닐 때만 자동 스크롤
                                      if (_shouldAutoScroll &&
                                          !_isUserScrolling &&
                                          _scrollController.hasClients) {
                                        _scrollController.animateTo(
                                          _scrollController
                                              .position
                                              .maxScrollExtent,
                                          duration: const Duration(
                                            milliseconds: 100,
                                          ),
                                          curve: Curves.easeOut,
                                        );
                                      }
                                    },
                                    onComplete: () {
                                      // 타이핑 완료 후 최종 스크롤
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            if (_scrollController.hasClients) {
                                              _scrollController.animateTo(
                                                _scrollController
                                                    .position
                                                    .maxScrollExtent,
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                curve: Curves.easeOut,
                                              );
                                            }
                                          });
                                    },
                                  )
                                  : _buildStaticBotMessage(msg.content),
                        );
                      }
                    }),
                    // 로딩 인디케이터
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 18),
                        child: TypingIndicator(),
                      ),
                  ],
                ),
              ),
            ),
            // 키보드 인셋을 고려한 컴포저 배치
            Padding(
              padding: EdgeInsets.only(bottom: keyboardInset),
              child: ChatComposer(
                controller: _controller,
                hintText: '어떻게 알았냐?',
                onSend: _handleSend,
                enabled: hasText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

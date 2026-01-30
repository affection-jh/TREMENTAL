import 'package:flutter/material.dart';
import 'package:tremental/chat/bot_text.dart';
import 'package:tremental/chat/chat_styles.dart';
import 'package:tremental/chat/models/chat_message.dart';
import 'package:tremental/chat/models/chat_suggestion.dart';
import 'package:tremental/chat/widgets/chat_composer.dart';
import 'package:tremental/chat/widgets/chat_intro_header.dart';
import 'package:tremental/chat/widgets/chat_top_bar.dart';
import 'package:tremental/chat/widgets/suggestion_grid.dart';
import 'package:tremental/chat/widgets/user_bubble.dart';
import 'package:tremental/theme/app_colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <ChatMessage>[];
  double _keyboardInset = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 초기 메시지들 (피그마 데모용)
    _messages.addAll([
      ChatMessage.user(
        '군 입대를 앞두고 삶의 흐름이 강제로 중단되는\n'
        '느낌 때문에 마음이 갑자기 심란해서 놀랐어',
      ),
    ]);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset =
        WidgetsBinding.instance.window.viewInsets.bottom /
        WidgetsBinding.instance.window.devicePixelRatio;

    final delta = bottomInset - _keyboardInset;

    // 키보드가 올라갈 때만(delta > 0) 강제 스크롤 보정
    // 키보드가 내려갈 때는(delta < 0) 시스템에 맡김
    if (delta > 0 && _scrollController.hasClients) {
      // postFrameCallback으로 레이아웃 완료 후 스크롤 보정
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final newOffset = _scrollController.offset + delta;
          // jumpTo를 사용하되, 범위를 제한하여 부드럽게 처리
          _scrollController.jumpTo(
            newOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          );
        }
      });
    }

    _keyboardInset = bottomInset;
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage.user(text));
      _controller.clear();
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
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = <ChatSuggestion>[
      const ChatSuggestion(date: '2025.02.23', title: '술먹고 추태를 부림'),
      const ChatSuggestion(date: '2025.02.23', title: '술먹고 연락해버림'),
    ];

    final hasText = _controller.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ChatTopBar(time: '14:15', address: '성동구 왕십리로 45'),
      // Scaffold 기본 리사이즈에 의존하지 않고(플랫폼별 차이), 우리가 인셋으로 정확히 밀어올립니다.
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                controller: _scrollController,
                padding: EdgeInsets.only(
                  left: ChatStyles.pagePadding.left,
                  right: ChatStyles.pagePadding.right,
                  bottom: 10 + _keyboardInset,
                ),
                children: [
                  const ChatIntroHeader(
                    title: '안녕하세요, 왜 놀랐나요?',
                    subtitle: '모든 대화는 암호화되어 보관돼요 안심하고 대화하세요',
                  ),
                  const SizedBox(height: 18),
                  // 동적으로 추가된 메시지들
                  ..._messages.map((msg) {
                    if (msg.type == ChatMessageType.user) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: UserBubble(text: msg.content),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: BotText(msg.content),
                      );
                    }
                  }),
                  // 초기 봇 프롬프트 (메시지가 하나일 때만 표시)
                  if (_messages.length == 1) ...[
                    const SizedBox(height: 18),
                    BotText(
                      '그러셨군요,',
                      normalStyle: ChatStyles.botPromptLead(context),
                      boldStyle: ChatStyles.botPromptLead(context),
                    ),
                    const SizedBox(height: 6),
                    BotText(
                      '혹시 **이 일과 관련이 있나요?**',
                      normalStyle: ChatStyles.botPromptQuestion(context),
                      boldStyle: ChatStyles.botPromptQuestionBold(context),
                    ),
                    const SizedBox(height: 14),
                    SuggestionGrid(items: suggestions),
                    BotText(
                      '그러셨군요,',
                      normalStyle: ChatStyles.botPromptLead(context),
                      boldStyle: ChatStyles.botPromptLead(context),
                    ),
                    const SizedBox(height: 6),
                    BotText(
                      '그러셨군요,',
                      normalStyle: ChatStyles.botPromptLead(context),
                      boldStyle: ChatStyles.botPromptLead(context),
                    ),
                    const SizedBox(height: 6),
                    BotText(
                      '그러셨군요,',
                      normalStyle: ChatStyles.botPromptLead(context),
                      boldStyle: ChatStyles.botPromptLead(context),
                    ),
                    const SizedBox(height: 6),
                    BotText(
                      '그러셨군요,\n\n\n\n\njsdf',
                      normalStyle: ChatStyles.botPromptLead(context),
                      boldStyle: ChatStyles.botPromptLead(context),
                    ),
                    const SizedBox(height: 6),
                  ],
                ],
              ),
            ),
            ChatComposer(
              controller: _controller,
              hintText: '어떻게 알았냐?',
              onSend: _handleSend,
              enabled: hasText,
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

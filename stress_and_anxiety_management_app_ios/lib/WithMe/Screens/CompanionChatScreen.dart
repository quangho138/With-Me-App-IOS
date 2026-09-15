import 'dart:async';

import 'package:flutter/material.dart';

import '../Components/WithMeBackdrop.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';
import 'CheckInScreen.dart';

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.fromUser,
    this.quickReplies = const [],
  });

  final String text;
  final bool fromUser;
  final List<String> quickReplies;
}

class CompanionChatScreen extends StatefulWidget {
  const CompanionChatScreen({super.key});

  @override
  State<CompanionChatScreen> createState() => _CompanionChatScreenState();
}

class _CompanionChatScreenState extends State<CompanionChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <ChatMessage>[];

  MascotExpression _expression = MascotExpression.happy;
  bool _typing = false;
  Timer? _replyTimer;

  @override
  void initState() {
    super.initState();
    _messages.add(
      const ChatMessage(
        text: "Hi, I'm here with you. How are you feeling today?",
        fromUser: false,
        quickReplies: [
          'Stressed',
          'Anxious',
          'Tired',
          'Actually okay',
        ],
      ),
    );
  }

  @override
  void dispose() {
    _replyTimer?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, fromUser: true));
      _input.clear();
      _typing = true;
      _expression = MascotExpression.thinking;
    });
    _scrollToEnd();

    _replyTimer?.cancel();
    _replyTimer = Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        final reply = _reply(text);
        _messages.add(reply);
        _expression = MascotExpression.listening;
      });
      _scrollToEnd();
    });
  }

  ChatMessage _reply(String input) {
    final lower = input.toLowerCase();

    if (lower.contains('stress') || lower.contains('overwhelm')) {
      return const ChatMessage(
        text:
            "That sounds heavy. Let's find out where it's coming from, one question at a time.",
        fromUser: false,
        quickReplies: ['Start a check-in', 'Just talk', 'Try breathing'],
      );
    }
    if (lower.contains('anxious') || lower.contains('worried')) {
      return const ChatMessage(
        text:
            'Thank you for telling me. Anxiety often shows up in the body first — shall we look there?',
        fromUser: false,
        quickReplies: ['Start a check-in', 'Try breathing'],
      );
    }
    if (lower.contains('okay') || lower.contains('good') || lower.contains('fine')) {
      return const ChatMessage(
        text: "I'm glad. Want to log it so we can see the pattern over time?",
        fromUser: false,
        quickReplies: ['Daily log', 'Start a check-in'],
      );
    }

    return const ChatMessage(
      text: "I'm listening. Tell me a little more about what's going on.",
      fromUser: false,
      quickReplies: ['Start a check-in', 'Try breathing'],
    );
  }

  void _handleQuickReply(String label) {
    if (label == 'Start a check-in') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CheckInScreen()),
      );
      return;
    }
    _send(label);
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: WithMeMotion.medium,
        curve: WithMeMotion.ease,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildWithMeTheme(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: WithMeBackdrop(
          dimmed: true,
          expression: _expression,
          speaking: _typing,
          child: SafeArea(
            child: Column(
              children: [
                _appBar(),
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(
                      WithMeSpace.lg,
                      WithMeSpace.sm,
                      WithMeSpace.lg,
                      WithMeSpace.lg,
                    ),
                    itemCount: _messages.length + (_typing ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == _messages.length) return const _TypingRow();
                      return _MessageRow(
                        message: _messages[i],
                        isLatest: i == _messages.length - 1,
                        onQuickReply: _handleQuickReply,
                      );
                    },
                  ),
                ),
                _composer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        WithMeSpace.md,
        WithMeSpace.sm,
        WithMeSpace.md,
        WithMeSpace.sm,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: WithMeSpace.sm,
          vertical: WithMeSpace.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.56),
          borderRadius: BorderRadius.circular(WithMeSpace.radiusLg),
          border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              color: WithMeColors.tealDeep,
              tooltip: 'Back',
            ),
            WithMeAvatarBadge(size: 42, expression: _expression),
            const SizedBox(width: WithMeSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'With Me Companion',
                    style: WithMeText.option.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _typing ? 'thinking…' : 'Here. With you.',
                    style: WithMeText.caption.copyWith(
                      color: WithMeColors.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _composer() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        WithMeSpace.md,
        0,
        WithMeSpace.md,
        WithMeSpace.md,
      ),
      padding: const EdgeInsets.fromLTRB(
        WithMeSpace.md,
        WithMeSpace.sm,
        WithMeSpace.md,
        WithMeSpace.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(WithMeSpace.radiusLg),
        boxShadow: WithMeSpace.cardShadow,
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _input,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: _send,
              style: WithMeText.option,
              decoration: InputDecoration(
                hintText: 'Tell me what’s going on…',
                hintStyle: WithMeText.body,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.72),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: WithMeSpace.lg,
                  vertical: WithMeSpace.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(WithMeSpace.radiusPill),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: WithMeSpace.sm),
          _circleButton(
            icon: Icons.mic_rounded,
            filled: false,
            onTap: () {},
            tooltip: 'Voice input',
          ),
          const SizedBox(width: WithMeSpace.sm),
          _circleButton(
            icon: Icons.send_rounded,
            filled: true,
            onTap: () => _send(_input.text),
            tooltip: 'Send',
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required bool filled,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: filled ? WithMeColors.teal : Colors.white.withValues(alpha: 0.72),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(
              icon,
              size: 21,
              color: filled ? Colors.white : WithMeColors.teal,
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  const _MessageRow({
    required this.message,
    required this.isLatest,
    required this.onQuickReply,
  });

  final ChatMessage message;
  final bool isLatest;
  final ValueChanged<String> onQuickReply;

  @override
  Widget build(BuildContext context) {
    final fromUser = message.fromUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: WithMeSpace.md),
      child: Column(
        crossAxisAlignment:
            fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                fromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!fromUser) ...[
                const WithMeAvatarBadge(size: 32, animate: false),
                const SizedBox(width: WithMeSpace.sm),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: WithMeSpace.lg,
                    vertical: WithMeSpace.md,
                  ),
                  decoration: BoxDecoration(
                    color: fromUser
                        ? WithMeColors.teal.withValues(alpha: 0.94)
                        : Colors.white.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(WithMeSpace.radiusMd),
                      topRight: const Radius.circular(WithMeSpace.radiusMd),
                      bottomLeft:
                          Radius.circular(fromUser ? WithMeSpace.radiusMd : 6),
                      bottomRight:
                          Radius.circular(fromUser ? 6 : WithMeSpace.radiusMd),
                    ),
                    border: Border.all(
                      color: fromUser
                          ? Colors.white.withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.9),
                    ),
                    boxShadow: WithMeSpace.cardShadow,
                  ),
                  child: Text(
                    message.text,
                    style: WithMeText.bubble.copyWith(
                      fontSize: 15.5,
                      color: fromUser ? Colors.white : WithMeColors.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!fromUser && isLatest && message.quickReplies.isNotEmpty) ...[
            const SizedBox(height: WithMeSpace.sm),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Wrap(
                spacing: WithMeSpace.sm,
                runSpacing: WithMeSpace.sm,
                children: [
                  for (final r in message.quickReplies)
                    _QuickReplyChip(label: r, onTap: () => onQuickReply(r)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickReplyChip extends StatelessWidget {
  const _QuickReplyChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(WithMeSpace.radiusPill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: WithMeSpace.lg,
            vertical: WithMeSpace.sm,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(WithMeSpace.radiusPill),
            border: Border.all(
              color: WithMeColors.teal.withValues(alpha: 0.42),
              width: 1.4,
            ),
          ),
          child: Text(
            label,
            style: WithMeText.option.copyWith(
              color: WithMeColors.teal,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _TypingRow extends StatefulWidget {
  const _TypingRow();

  @override
  State<_TypingRow> createState() => _TypingRowState();
}

class _TypingRowState extends State<_TypingRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: WithMeSpace.md),
      child: Row(
        children: [
          const WithMeAvatarBadge(
            size: 32,
            expression: MascotExpression.thinking,
          ),
          const SizedBox(width: WithMeSpace.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: WithMeSpace.lg,
              vertical: WithMeSpace.md,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.86),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(WithMeSpace.radiusMd),
                topRight: Radius.circular(WithMeSpace.radiusMd),
                bottomRight: Radius.circular(WithMeSpace.radiusMd),
                bottomLeft: Radius.circular(6),
              ),
              boxShadow: WithMeSpace.cardShadow,
            ),
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          -3 *
                              Curves.easeInOut.transform(
                                _bounce((_c.value + i * 0.18) % 1.0),
                              ),
                        ),
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: WithMeColors.teal,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _bounce(double t) =>
      t < 0.6 ? (1 - (t / 0.3 - 1).abs()).clamp(0.0, 1.0).toDouble() : 0.0;
}

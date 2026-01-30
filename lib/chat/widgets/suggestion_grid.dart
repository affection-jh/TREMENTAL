import 'package:flutter/material.dart';
import 'package:tremental/chat/chat_styles.dart';
import 'package:tremental/chat/models/chat_suggestion.dart';
import 'package:tremental/theme/app_colors.dart';

class SuggestionGrid extends StatelessWidget {
  const SuggestionGrid({super.key, required this.items, this.onTap});

  final List<ChatSuggestion> items;
  final void Function(ChatSuggestion item)? onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        const gap = 12.0;
        final itemWidth = (availableWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: _SuggestionCard(
                  item: item,
                  onTap: onTap == null ? null : () => onTap!(item),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.item, this.onTap});

  final ChatSuggestion item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SizedBox(
          height: 62,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.date, style: ChatStyles.botMeta(context)),
              const SizedBox(height: 8),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tremental/theme/app_text_styles.dart';
import '../theme/app_colors.dart';

/// 대화 카드 모드
enum ConversationCardMode {
  /// 대화가 필요해요 (회색 배경, 시간 표시)
  scheduled,

  /// 지난 대화 둘러보기 (다크 카드 배경, 화살표 표시)
  past,
}

/// 대화 카드 (대화가 필요해요 / 지난 대화 둘러보기)
class ConversationCard extends StatelessWidget {
  final String date;
  final String? address;
  final String? time;
  final String? topic;
  final String? record;
  final ConversationCardMode mode;
  final VoidCallback? onTap;

  const ConversationCard({
    super.key,
    required this.date,
    this.address,
    this.time,
    this.topic,
    this.record,
    this.mode = ConversationCardMode.scheduled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 두 모드 모두 동일한 디자인 (다크 카드 배경)
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.onCardPrimary,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: AppTextStyles.notoSansKr(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // scheduled 모드: address 표시, past 모드: topic 표시
                  Text(
                    mode == ConversationCardMode.scheduled
                        ? (address ?? '')
                        : (topic ?? '대화'),
                    style: AppTextStyles.notoSansKr(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            // scheduled 모드: 시간 표시, past 모드: 화살표 표시
            if (mode == ConversationCardMode.scheduled && time != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (record != null)
                    SvgPicture.asset(
                      'assets/icons/phone.svg',
                      width: 10,
                      height: 10,
                      colorFilter: ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    time!,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              )
            else if (mode == ConversationCardMode.past)
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}

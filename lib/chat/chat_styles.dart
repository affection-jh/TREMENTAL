import 'package:flutter/material.dart';
import 'package:tremental/theme/app_colors.dart';

class ChatStyles {
  static const EdgeInsets pagePadding = EdgeInsets.only(left: 20, right: 4);

  static const double topSectionSpacing = 14;
  static const double messageSpacing = 12;

  static TextStyle botTitle(BuildContext context) {
    return const TextStyle(
      fontSize: 18,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle botSubtitle(BuildContext context) {
    return TextStyle(
      fontSize: 12.5,
      height: 1.35,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary.withOpacity(0.55),
    );
  }

  static TextStyle botBody(BuildContext context) {
    return const TextStyle(
      fontSize: 14.5,
      height: 1.45,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle botBodyBold(BuildContext context) {
    return botBody(context).copyWith(fontWeight: FontWeight.w700);
  }

  /// 대화 중간의 챗봇 프롬프트(예: "그렇군요," 다음 줄 큰 질문)용
  static TextStyle botPromptLead(BuildContext context) {
    return TextStyle(
      fontSize: 14.5,
      height: 1.25,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary.withOpacity(0.55),
    );
  }

  static TextStyle botPromptQuestion(BuildContext context) {
    return const TextStyle(
      fontSize: 20,
      height: 1.1,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle botPromptQuestionBold(BuildContext context) {
    return botPromptQuestion(context).copyWith(fontWeight: FontWeight.w600);
  }

  static TextStyle botMeta(BuildContext context) {
    return TextStyle(
      fontSize: 12.5,
      height: 1.25,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary.withOpacity(0.55),
    );
  }

  static TextStyle userBubbleText(BuildContext context) {
    return const TextStyle(
      fontSize: 14.5,
      height: 1.35,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tremental/theme/app_colors.dart';

class ChatTopBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatTopBar({
    super.key,
    required this.time,
    required this.address,
    this.onBack,
  });

  final String time;
  final String address;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 44,
      leading: IconButton(
        onPressed: onBack ?? () => Navigator.maybePop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 28),
        color: AppColors.primary,
      ),
      titleSpacing: 0,
      title: Align(
        alignment: Alignment.bottomLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              time,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.1,
                color: AppColors.textPrimary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '·',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withOpacity(0.6),
                ),
              ),
            ),
            Text(
              address,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary.withOpacity(0.6),
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
      actions: [_TopBarIcon(onTap: () {}), SizedBox(width: 6)],
    );
  }
}

class _TopBarIcon extends StatelessWidget {
  const _TopBarIcon({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        'assets/icons/phone.svg',
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
      ),
    );
  }
}

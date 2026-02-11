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
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: AppColors.primary,
      ),
      titleSpacing: 0,
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            address,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withOpacity(0.6),
              height: 1.1,
            ),
          ),
        ],
      ),

      //actions: [_TopBarIcon(onTap: () {}), SizedBox(width: 6)],
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
        width: 12,
        height: 12,
        colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SocialIconButton extends StatelessWidget {
  final Widget iconWidget;
  final VoidCallback onPressed;

  const SocialIconButton({
    super.key,
    required this.iconWidget,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderColor),
      ),
      child: IconButton(
        icon: iconWidget,
        onPressed: onPressed,
        splashRadius: 32,
      ),
    );
  }
}

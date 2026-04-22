import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../constants/app_sizes.dart';
import 'custom_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;
  final Widget? customIcon;

  const EmptyStateWidget({
    required this.title,
    required this.subtitle,
    this.icon,
    this.buttonLabel,
    this.onButtonPressed,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical: AppSizes.paddingXL,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon or Custom Icon
            if (customIcon != null)
              customIcon!
            else if (icon != null)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: AppSizes.iconXL,
                  color: AppColors.primary,
                ),
              )
            else
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inbox,
                  size: AppSizes.iconXL,
                  color: AppColors.primary,
                ),
              ),
            const SizedBox(height: AppSizes.paddingXL),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppFonts.headingS,
                fontWeight: FontWeight.bold,
                color: AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppFonts.bodyM,
                color: AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // Button
            if (buttonLabel != null && onButtonPressed != null)
              CustomButton(
                label: buttonLabel!,
                onPressed: onButtonPressed,
                width: 200,
              ),
          ],
        ),
      ),
    );
  }
}

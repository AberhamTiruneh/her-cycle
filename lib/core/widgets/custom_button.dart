import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../constants/app_sizes.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final ButtonType buttonType;
  final double? width;
  final double? height;

  const CustomButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.buttonType = ButtonType.primary,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isClickable = !isLoading && !isDisabled && onPressed != null;

    switch (buttonType) {
      case ButtonType.primary:
        return _buildPrimaryButton(context, isClickable);
      case ButtonType.secondary:
        return _buildSecondaryButton(context, isClickable);
      case ButtonType.text:
        return _buildTextButton(context, isClickable);
    }
  }

  Widget _buildPrimaryButton(BuildContext context, bool isClickable) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? AppSizes.buttonHeightM,
      child: Container(
        decoration: BoxDecoration(
          gradient: isClickable ? AppColors.primaryGradient : null,
          color: !isClickable ? Colors.grey[400] : null,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          boxShadow: [
            if (isClickable)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: AppSizes.shadowBlur,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isClickable ? onPressed : null,
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isClickable ? Colors.white : Colors.grey,
                      ),
                      strokeWidth: 2,
                    ),
                  )
                else if (icon != null)
                  Icon(icon, color: Colors.white, size: AppSizes.iconM),
                if (!isLoading && icon != null)
                  const SizedBox(width: AppSizes.paddingS),
                if (!isLoading)
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: AppFonts.titleM,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, bool isClickable) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? AppSizes.buttonHeightM,
      child: OutlinedButton(
        onPressed: isClickable ? onPressed : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isClickable ? AppColors.primary : Colors.grey[400]!,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isClickable ? AppColors.primary : Colors.grey,
                  ),
                  strokeWidth: 2,
                ),
              )
            else if (icon != null)
              Icon(
                icon,
                color: isClickable ? AppColors.primary : Colors.grey,
                size: AppSizes.iconM,
              ),
            if (!isLoading && icon != null)
              const SizedBox(width: AppSizes.paddingS),
            if (!isLoading)
              Text(
                label,
                style: TextStyle(
                  fontSize: AppFonts.titleM,
                  fontWeight: FontWeight.w600,
                  color:
                      isClickable ? AppColors.primary : Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextButton(BuildContext context, bool isClickable) {
    return TextButton(
      onPressed: isClickable ? onPressed : null,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical: AppSizes.paddingM,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  isClickable ? AppColors.primary : Colors.grey,
                ),
                strokeWidth: 2,
              ),
            )
          else if (icon != null)
            Icon(
              icon,
              color: isClickable ? AppColors.primary : Colors.grey,
              size: AppSizes.iconM,
            ),
          if (!isLoading && icon != null)
            const SizedBox(width: AppSizes.paddingS),
          if (!isLoading)
            Text(
              label,
              style: TextStyle(
                fontSize: AppFonts.titleM,
                fontWeight: FontWeight.w600,
                color: isClickable ? AppColors.primary : Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}

enum ButtonType { primary, secondary, text }

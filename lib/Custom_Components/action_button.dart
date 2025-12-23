import 'package:flutter/material.dart';

import '../Constants/app_color.dart';
import '../services/responsive.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final IconData? icon;
  final bool enabled;
  final EdgeInsetsGeometry? margin;

  const ActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.enabled = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final Color backgroundColor = !enabled
        ? AppColors.hintTextColor
        : (isPrimary ? AppColors.secondaryColor : AppColors.white);

    final Color textColor = !enabled
        ? Colors.grey
        : (isPrimary ? AppColors.white : AppColors.borderColor);

    return Container(
      color: AppColors.white,
      width: double.infinity,
      height: r.scale(50),
      margin: margin ?? EdgeInsets.symmetric(vertical: r.scale(5)),
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(r.scale(16)),
            side: !enabled
                ? BorderSide.none
                : (isPrimary
                    ? BorderSide.none
                    : BorderSide(
                        color: AppColors.hintTextColor,
                        width: r.scale(1),
                      )),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: r.scale(18), color: textColor),
              SizedBox(width: r.scale(6)),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: r.font(14),
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

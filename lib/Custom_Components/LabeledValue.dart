import 'package:flutter/material.dart';
import '../Constants/app_color.dart';
import '../services/responsive.dart';

class LabeledValue extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const LabeledValue({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    return Container(
      padding:
          EdgeInsets.symmetric(vertical: r.scale(6), horizontal: r.scale(8)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(r.scale(8)),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: r.font(12),
              color: AppColors.primaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: r.scale(6)),
          Text(
            value,
            style: TextStyle(
              fontSize: r.font(13),
              color: AppColors.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

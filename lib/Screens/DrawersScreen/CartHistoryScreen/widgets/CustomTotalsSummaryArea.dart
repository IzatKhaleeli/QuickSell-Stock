import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../Constants/app_color.dart';
import '../../../../services/LocalizationService.dart';

class CustomTotalsSummaryArea extends StatelessWidget {
  final int expenses;
  final int sales;
  final bool isLoading;

  const CustomTotalsSummaryArea({
    super.key,
    required this.expenses,
    required this.sales,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    var appLocalization =
        Provider.of<LocalizationService>(context, listen: false);
    int net = sales - expenses;

    return Container(
      margin: EdgeInsets.only(top: 20.h),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12.r), // scaled borderRadius
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow(appLocalization.getLocalizedString('expenses'),
              expenses, isLoading),
          _buildSummaryRow(
              appLocalization.getLocalizedString('sales'), sales, isLoading),
          _buildSummaryRow(
              appLocalization.getLocalizedString('net'), net, isLoading,
              isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, int amount, isLoading,
      {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18.sp,
              color: AppColors.primaryColor, // Set text color to green
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.0.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  ),
                )
              : Text(
                  '${amount == 0 ? 'N/A' : amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18.sp, // scaled font size
                    color: AppColors.primaryColor, // Set text color to green
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
        ],
      ),
    );
  }
}

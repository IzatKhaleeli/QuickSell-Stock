import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Constants/app_color.dart';
import '../../../../services/LocalizationService.dart';

class CustomDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    Key? key,
    required this.expenses,
    required this.selectedValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appLocalization =
        Provider.of<LocalizationService>(context, listen: false);

    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / 390).clamp(0.85, 1.2);

    final horizontalPadding = 12.0 * scale;
    final borderRadius = 8.0 * scale;
    final spreadRadius = 1.0 * scale;
    final blurRadius = 2.0 * scale;
    final offsetY = 3.0 * scale;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
            spreadRadius: spreadRadius,
            blurRadius: blurRadius,
            offset: Offset(0, offsetY),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(
            appLocalization.getLocalizedString("selectExpense"),
            style: TextStyle(fontSize: 13),
          ),
          isExpanded: true,
          items: expenses.map((item) {
            return DropdownMenuItem<String>(
              value: item['id'], // value passed in callback
              child: Text(
                item['name'] ?? '',
                style: TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

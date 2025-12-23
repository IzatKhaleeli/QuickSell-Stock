import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Constants/app_color.dart';
import '../../../../Services/LocalizationService.dart';

class CheckoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CheckoutButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    var appLocalization =
        Provider.of<LocalizationService>(context, listen: false);
    final screenSize = MediaQuery.of(context).size;
    final scale = (screenSize.width / 390).clamp(0.70, 1.2);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          '${appLocalization.getLocalizedString("submit")} 🛒',
          style: TextStyle(
            fontSize: 18 * scale,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

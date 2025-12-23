import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quick_sell/Constants/app_color.dart';

import '../../../../services/LocalizationService.dart';

enum PaymentMethod { visa, cash, mix }

class PaymentMethodPopup extends StatefulWidget {
  final double total;
  final Function(PaymentMethod method, double cashAmount, double visaAmount)
      onSubmit;

  const PaymentMethodPopup({
    super.key,
    required this.total,
    required this.onSubmit,
  });

  @override
  State<PaymentMethodPopup> createState() => _PaymentMethodPopupState();
}

class _PaymentMethodPopupState extends State<PaymentMethodPopup> {
  PaymentMethod _selectedMethod = PaymentMethod.visa;
  final TextEditingController _cashController = TextEditingController();

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization =
        Provider.of<LocalizationService>(context, listen: false);

    final screenSize = MediaQuery.of(context).size;
    final scale = (screenSize.width / 390).clamp(0.7, 1.2);

    double total = widget.total;
    double cashAmount = 0.0;
    double visaAmount = total;

    if (_selectedMethod == PaymentMethod.mix) {
      cashAmount = double.tryParse(_cashController.text) ?? 0.0;
      if (cashAmount > total) {
        cashAmount = total;
        _cashController.text = total.toString();
      }
      visaAmount = total - cashAmount;
    } else if (_selectedMethod == PaymentMethod.cash) {
      cashAmount = total;
      visaAmount = 0.0;
    }

    return AlertDialog(
      title: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            appLocalization.getLocalizedString("choosePaymentMethod"),
            style: TextStyle(
              color: AppColors.hintTextColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            total.toStringAsFixed(2),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: scale,
            child: RadioListTile<PaymentMethod>(
              contentPadding: EdgeInsets.zero,
              title: Transform.scale(
                scale: 1 / scale,
                child: Text(
                  appLocalization.getLocalizedString("visa"),
                  style: TextStyle(fontSize: 13),
                ),
              ),
              value: PaymentMethod.visa,
              groupValue: _selectedMethod,
              activeColor: AppColors.secondaryColor,
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
            ),
          ),
          Transform.scale(
            scale: scale,
            child: RadioListTile<PaymentMethod>(
              contentPadding: EdgeInsets.zero,
              title: Transform.scale(
                scale: 1 / scale,
                child: Text(
                  appLocalization.getLocalizedString("cash"),
                  style: TextStyle(fontSize: 13),
                ),
              ),
              value: PaymentMethod.cash,
              activeColor: AppColors.secondaryColor,
              groupValue: _selectedMethod,
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
            ),
          ),
          Transform.scale(
            scale: scale,
            child: RadioListTile<PaymentMethod>(
              contentPadding: EdgeInsets.zero,
              title: Transform.scale(
                scale: 1 / scale,
                child: Text(
                  appLocalization.getLocalizedString("visaAndCash"),
                  style: TextStyle(fontSize: 13),
                ),
              ),
              value: PaymentMethod.mix,
              activeColor: AppColors.secondaryColor,
              groupValue: _selectedMethod,
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
            ),
          ),
          if (_selectedMethod == PaymentMethod.mix)
            TextField(
              controller: _cashController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: appLocalization.getLocalizedString("cashAmount"),
                labelStyle: TextStyle(fontSize: 13),
                filled: true,
                fillColor: AppColors.backgroundColor,
              ),
              style: TextStyle(fontSize: 13),
              onChanged: (_) => setState(() {}),
            ),
          const SizedBox(height: 10),
          if (_selectedMethod == PaymentMethod.cash)
            Text(
              "${appLocalization.getLocalizedString("cash")}: ${cashAmount.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          if (_selectedMethod == PaymentMethod.visa)
            Text(
                "${appLocalization.getLocalizedString("visa")}: ${visaAmount.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          if (_selectedMethod == PaymentMethod.mix)
            Text(
                "${appLocalization.getLocalizedString("cash")}: ${cashAmount.toStringAsFixed(2)}, ${appLocalization.getLocalizedString("visa")}: ${visaAmount.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                appLocalization.getLocalizedString("cancel"),
                style: TextStyle(fontSize: 13),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onSubmit(_selectedMethod, cashAmount, visaAmount);
              },
              child: Text(
                appLocalization.getLocalizedString("submit"),
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

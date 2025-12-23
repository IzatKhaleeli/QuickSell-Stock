import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_sell/Constants/app_color.dart';
import 'services/LocalizationService.dart';
import 'services/globalError.dart';

class GlobalErrorListener extends StatelessWidget {
  final Widget child;

  const GlobalErrorListener({Key? key, required this.child}) : super(key: key);

  static bool _dialogShowing = false;

  @override
  Widget build(BuildContext context) {
    var appLocalization =
        Provider.of<LocalizationService>(context, listen: false);

    return ValueListenableBuilder<String?>(
      valueListenable: GlobalErrorNotifier.errorTextNotifier,
      builder: (context, errorText, _) {
        if (errorText != null && !_dialogShowing) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            _dialogShowing = true;

            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  appLocalization.getLocalizedString('error'),
                  style: const TextStyle(color: AppColors.errorColor),
                ),
                content: Text(errorText),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(appLocalization.getLocalizedString('ok')),
                  ),
                ],
              ),
            );

            GlobalErrorNotifier.clearError();
            _dialogShowing = false;
          });
        }
        return child;
      },
    );
  }
}

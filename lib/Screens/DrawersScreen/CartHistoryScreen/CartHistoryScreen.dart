import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Constants/app_color.dart';
import '../../../services/LocalizationService.dart';
import '../../../States/HistoryCartState.dart';
import 'widgets/CustomFilterArea.dart';
import 'widgets/CustomHistoryItemList.dart';

class CartHistoryScreen extends StatefulWidget {
  const CartHistoryScreen({super.key});

  @override
  State<CartHistoryScreen> createState() => _CartHistoryScreenState();
}

class _CartHistoryScreenState extends State<CartHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    var appLocalization =
        Provider.of<LocalizationService>(context, listen: false);

    var historyCartState = Provider.of<HistoryCartState>(context);
    var carts = historyCartState.carts;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalization.getLocalizedString('salesHistory'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.lighterTextColor,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(
          color: AppColors.lighterTextColor,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomFilterArea(appLocalization: appLocalization),
            const SizedBox(height: 20),
            Expanded(
              child: carts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            appLocalization.getLocalizedString('noHistory'),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : CustomHistoryItemList(appLocalization: appLocalization),
            )
          ],
        ),
      ),
    );
  }
}

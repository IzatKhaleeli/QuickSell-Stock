import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Constants/app_color.dart';
import '../../../Services/LocalizationService.dart';
import '../../../States/HistoryCartState.dart';
import 'widgets/CustomFilterArea.dart';
import 'widgets/CustomHistoryItemList.dart';

class CartHistoryScreen extends StatefulWidget {
  @override
  State<CartHistoryScreen> createState() => _CartHistoryScreenState();
}

class _CartHistoryScreenState extends State<CartHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    var appLocalization =
        Provider.of<LocalizationService>(context, listen: false);

    // Get the current carts list from the provider
    var historyCartState = Provider.of<HistoryCartState>(context);
    var carts = historyCartState.carts;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalization
              .getLocalizedString('salesHistory'), // More professional name
          textAlign: TextAlign.center, // Center the title
          style: TextStyle(
            color: AppColors.lighterTextColor, // Text color from AppColors
          ),
        ),
        backgroundColor: AppColors.primaryColor, // AppBar with primary color
        iconTheme: IconThemeData(
          color: AppColors
              .lighterTextColor, // Set the back arrow color to match text color
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Area: Date From and Date To
            CustomFilterArea(appLocalization: appLocalization),

            const SizedBox(height: 20),

            // List of Cards: History Items
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../States/HistoryCartState.dart';
import '../../../../Services/LocalizationService.dart';
import 'CustomHistoryCard.dart'; // Import HistoryCard widget

class CustomHistoryItemList extends StatelessWidget {
  final LocalizationService
      appLocalization; // Add LocalizationService parameter

  // Accept LocalizationService as a parameter in the constructor
  CustomHistoryItemList({Key? key, required this.appLocalization})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var historyCartState = Provider.of<HistoryCartState>(context);
    var carts = historyCartState.carts;
    return ListView.builder(
      itemCount: carts.length,
      itemBuilder: (context, index) {
        final item = carts[index];

        return CustomHistoryCard(
          id: item.id,
          transactionDate: item.createdAt.toString(),
          createdBy: item.createdBy.toString(),
          totalPrice: item.totalPrice.toString(),
        );
      },
    );
  }
}

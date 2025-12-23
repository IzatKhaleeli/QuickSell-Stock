import 'package:flutter/material.dart';
import 'dart:ui'; // Import to use ImageFilter.blur

import '../../../../Constants/app_color.dart';
import '../../../../Models/ItemCartModel.dart';
import '../../../../services/LocalizationService.dart';
import 'CustomDetailRow.dart';

class CustomItemOrderItemsDialog extends StatelessWidget {
  final List<ItemCart> itemOrderItems;
  final LocalizationService appLocalization;
  final String orderId;

  CustomItemOrderItemsDialog(
      {required this.itemOrderItems,
      required this.appLocalization,
      required this.orderId});

  @override
  Widget build(BuildContext context) {
    print("itemOrderItems:${itemOrderItems}");
    return Dialog(
      backgroundColor: Colors.transparent, // Make the dialog itself transparent
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      insetPadding:
          EdgeInsets.all(20), // Optional: Add padding for dialog positioning
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(12), // Rounded corners for the container
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 4), // Apply blur effect
          child: Container(
            padding: EdgeInsets.all(12),
            height: 625,
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(0.6), // Semi-transparent white background
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors
                              .primaryColor, // Color of the bottom border
                          width: 2, // Thickness of the bottom border
                        ),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12), // Adjust padding
                    child: Text(
                      orderId.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        color: AppColors.primaryColor, // White text color
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: AppColors.primaryColor
                                .withOpacity(0.4), // Shadow color
                            offset: Offset(2, 2), // Shadow offset
                            blurRadius: 5, // Blur effect
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: itemOrderItems.length,
                    itemBuilder: (context, index) {
                      final item = itemOrderItems[index];
                      return Card(
                        color: AppColors.secondaryColor
                            .withOpacity(0.6), // 50% opacity
                        margin: EdgeInsets.symmetric(vertical: 8),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    CustomDetailRow(
                                      title: '#: ',
                                      value: (index + 1)
                                          .toString(), // Format the date before displaying
                                    ),
                                    if (item.itemName != null &&
                                        item.itemName!.trim() != "")
                                      CustomDetailRow(
                                        title:
                                            '${appLocalization.getLocalizedString('name')}: ',
                                        value: item.itemName!,
                                      ),
                                    // CustomDetailRow(
                                    //   title: '${appLocalization.getLocalizedString('size')}: ',
                                    //   value: item.itemSizeName.toString(),
                                    // ),
                                    CustomDetailRow(
                                      title:
                                          '${appLocalization.getLocalizedString('actualPrice')}: ',
                                      value:
                                          item.purchasePrice.toStringAsFixed(2),
                                    ),
                                    CustomDetailRow(
                                      title:
                                          '${appLocalization.getLocalizedString('sellingPrice')}: ',
                                      value:
                                          item.sellingPrice.toStringAsFixed(2),
                                    ),
                                    CustomDetailRow(
                                      title:
                                          '${appLocalization.getLocalizedString('quantity')}: ',
                                      value: item.quantity.toString(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text(
                        appLocalization.getLocalizedString("exit"),
                        style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

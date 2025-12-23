import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../Constants/app_color.dart';
import '../../../../Custom_Components/CustomLoadingAvatar.dart';
import '../../../../Models/ItemCartModel.dart';
import '../../../../services/LocalizationService.dart';
import '../../../../api_services/CartService.dart';
import '../../../../services/CheckConnectivity.dart';
import '../../../../Utils/date_helper.dart';
import '../../../LoginScreen/Custom_Widgets/CustomFailedPopup.dart';
import 'CustomDetailRow.dart';
import 'CustomItemOrderItemsDialog.dart';

class CustomHistoryCard extends StatefulWidget {
  final int id;
  final String transactionDate;
  final String createdBy;
  final String totalPrice;

  const CustomHistoryCard({
    required this.id,
    required this.transactionDate,
    required this.createdBy,
    required this.totalPrice,
  });

  @override
  _CustomHistoryCardState createState() => _CustomHistoryCardState();
}

class _CustomHistoryCardState extends State<CustomHistoryCard> {
  @override
  Widget build(BuildContext context) {
    var appLocalization =
        Provider.of<LocalizationService>(context, listen: false);
    return Card(
      elevation: 1.5,
      margin: EdgeInsets.symmetric(vertical: 2.h, horizontal: 1.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.secondaryColor,
          backgroundColor: AppColors.backgroundColor,
          collapsedBackgroundColor: AppColors.backgroundColor,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          expandedAlignment: Alignment.centerLeft,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateHelper.formatTransactionDate(widget.transactionDate),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.primaryTextColor,
                ),
              ),
              Text(
                widget.id.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13, // scaled font size
                  color: AppColors.primaryTextColor,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomDetailRow(
                    title:
                        '${appLocalization.getLocalizedString('transactionDate')}: ',
                    value: DateHelper.formatTransactionDateToDate(widget
                        .transactionDate), // Format the date before displaying,
                  ),
                  const SizedBox(height: 5),
                  CustomDetailRow(
                    title:
                        '${appLocalization.getLocalizedString('transactionTime')}: ',
                    value: DateHelper.formatTransactionDateToTime(widget
                        .transactionDate), // Format the date before displaying,
                  ),
                  const SizedBox(height: 5),
                  CustomDetailRow(
                    title: '${appLocalization.getLocalizedString('id')}: ',
                    value: widget.id.toString(),
                  ),
                  const SizedBox(height: 5),
                  CustomDetailRow(
                    title:
                        '${appLocalization.getLocalizedString('createdBy')}: ',
                    value: widget.createdBy,
                  ),
                  const SizedBox(height: 5),
                  CustomDetailRow(
                    title:
                        '${appLocalization.getLocalizedString('totalPrice')}: ',
                    value: widget.totalPrice,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () async {
                          _handleOrderItemsFetch(context, appLocalization);
                        },
                        icon: Icon(
                          Icons.visibility,
                          size: 20, // scaled icon size
                        ), // Use an eye icon for the "View" action
                        color: AppColors.secondaryColor, // Set the icon color
                        tooltip:
                            '${appLocalization.getLocalizedString('view')}', // Tooltip for accessibility
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleOrderItemsFetch(
      BuildContext context, LocalizationService appLocalization) async {
    try {
      bool isConnected = await checkConnectivity();
      if (!isConnected) {
        showLoginFailedDialog(
          context,
          appLocalization.getLocalizedString('noInternetConnection'),
          appLocalization.getLocalizedString('noInternet'),
          appLocalization.selectedLanguageCode,
          appLocalization.getLocalizedString('ok'),
        );
        return;
      }

      showLoadingAvatar(context);
      List<ItemCart> itemOrderItems =
          await CartService.fetchOrderItems(context, widget.id);
      Navigator.of(context).pop(); // Close the loading indicator
      _showItemListDialog(context, itemOrderItems, appLocalization);
    } catch (e) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${appLocalization.getLocalizedString("errorFailedUnexpected")}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      print("Error fetching order items: $e");
    }
  }

  void _showItemListDialog(BuildContext context, List<ItemCart> itemOrderItems,
      LocalizationService appLocalization) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomItemOrderItemsDialog(
          itemOrderItems: itemOrderItems,
          appLocalization: appLocalization,
          orderId: widget.id.toString(),
        );
      },
    );
  }
}

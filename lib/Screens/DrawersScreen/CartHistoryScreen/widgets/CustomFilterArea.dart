import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../Constants/app_color.dart';
import '../../../../Custom_Components/CustomLoadingAvatar.dart';
import '../../../../Models/CartModel.dart';
import '../../../../Services/CartService.dart';
import '../../../../Services/CheckConnectivity.dart';
import '../../../../Services/LocalizationService.dart';
import '../../../../States/HistoryCartState.dart';
import '../../../../Utils/date_helper.dart';
import '../../../LoginScreen/Custom_Widgets/CustomFailedPopup.dart';

class CustomFilterArea extends StatefulWidget {
  final LocalizationService appLocalization;

  const CustomFilterArea({Key? key, required this.appLocalization})
      : super(key: key);

  @override
  State<CustomFilterArea> createState() => _CustomFilterAreaState();
}

class _CustomFilterAreaState extends State<CustomFilterArea> {
  DateTime fromDate = DateTime.now(); // Initially empty
  DateTime toDate = DateTime.now(); // Initially empty
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    // Set initial dates to today's date
    fromDate = DateTime(
        fromDate.year, fromDate.month, fromDate.day); // Reset to 00:00:00
    toDate = DateTime(toDate.year, toDate.month, toDate.day);
  }

  Future<void> _selectDate(bool isFrom) async {
    final DateTime initialDate =
        isFrom ? (fromDate ?? DateTime.now()) : (toDate ?? DateTime.now());
    print("Initial Date: $initialDate"); // Debugging line
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          // If 'fromDate' is picked, check if it's after 'toDate'
          fromDate = picked;
          if (toDate != null &&
              fromDate != null &&
              fromDate!.isAfter(toDate!)) {
            // If 'fromDate' is after 'toDate', set 'toDate' to 'fromDate'
            toDate = fromDate;
          }
        } else {
          // If 'toDate' is picked, check if it's before 'fromDate'
          toDate = picked;
          if (fromDate != null &&
              toDate != null &&
              toDate!.isBefore(fromDate!)) {
            // If 'toDate' is before 'fromDate', set 'fromDate' to 'toDate'
            fromDate = toDate;
          }
        }
      });
    }
  }

  Widget _buildDateBox(
      String label, DateTime? date, bool isFrom, double scale) {
    return GestureDetector(
      onTap: () => _selectDate(isFrom), // Make the entire field tappable
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                color: AppColors.secondaryColor, size: 20 * scale),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.appLocalization
                        .getLocalizedString(isFrom ? 'dateFrom' : 'dateTo'),
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          date != null ? _dateFormat.format(date) : '--',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / 390).clamp(0.8, 1.2);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey, // Set your desired color for the bottom line
            width: 1.0, // Adjust the width of the line
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 300) {
              // Stack vertically on smaller screens
              return Column(
                children: [
                  _buildDateBox(
                      widget.appLocalization.getLocalizedString('dateFrom'),
                      fromDate,
                      true,
                      scale),
                  const SizedBox(height: 2),
                  _buildDateBox(
                      widget.appLocalization.getLocalizedString('dateTo'),
                      toDate,
                      false,
                      scale),
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      iconSize: 24 * scale,
                      icon: const Icon(Icons.filter_alt,
                          color: AppColors.secondaryColor),
                      tooltip:
                          widget.appLocalization.getLocalizedString('filter'),
                      onPressed: _applyFilter,
                    ),
                  ),
                ],
              );
            } else {
              // Side by side on larger screens
              return Row(
                children: [
                  Expanded(
                    child: _buildDateBox(
                        widget.appLocalization.getLocalizedString('dateFrom'),
                        fromDate,
                        true,
                        scale),
                  ),
                  Container(
                    height: 40, // Set a fixed height for the divider
                    child: const VerticalDivider(
                      color: AppColors
                          .hintTextColor, // Set your desired color for the divider
                      thickness:
                          1.0, // Adjust the thickness of the divider line
                      width: 20, // Space around the divider
                    ),
                  ),
                  Expanded(
                    child: _buildDateBox(
                        widget.appLocalization.getLocalizedString('dateTo'),
                        toDate,
                        false,
                        scale),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor, // Background color
                        borderRadius: BorderRadius.circular(8 * scale),
                      ),
                      child: IconButton(
                        iconSize: 24 * scale,
                        icon: const Icon(Icons.search,
                            color: AppColors.primaryColor),
                        tooltip:
                            widget.appLocalization.getLocalizedString('filter'),
                        onPressed: _applyFilter,
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _applyFilter() async {
    bool isConnected = await checkConnectivity();
    if (!isConnected) {
      showLoginFailedDialog(
        context,
        widget.appLocalization.getLocalizedString('noInternetConnection'),
        widget.appLocalization.getLocalizedString('noInternet'),
        widget.appLocalization.selectedLanguageCode,
        widget.appLocalization.getLocalizedString('ok'),
      );
      return;
    }

    if (fromDate == null || toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.appLocalization
                  .getLocalizedString('pleaseSelectDateRange') ??
              'Please select both From and To dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String fromDateStr = DateHelper.formatDateOnly(fromDate);
    String toDateStr = DateHelper.formatDateOnly(toDate);
    showLoadingAvatar(context);
    try {
      List<CartModel> historyCarts =
          await CartService.fetchCarts(context, fromDateStr, toDateStr);
      HistoryCartState historyCartState =
          Provider.of<HistoryCartState>(context, listen: false);
      historyCartState.carts = historyCarts;
      Navigator.of(context).pop(); // Always remove the loading avatar
    } catch (e) {
      Navigator.of(context).pop();
      // Optional: show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch carts: $e')),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../Constants/app_color.dart';
import '../../../../Custom_Components/CustomLoadingAvatar.dart';
import '../../../../Models/CartModel.dart';
import '../../../../services/LocalizationService.dart';
import '../../../../api_services/CartService.dart';
import '../../../../services/CheckConnectivity.dart';
import '../../../../States/HistoryCartState.dart';
import '../../../../Utils/date_helper.dart';
import '../../../LoginScreen/Custom_Widgets/CustomFailedPopup.dart';

class CustomFilterArea extends StatefulWidget {
  final LocalizationService appLocalization;

  const CustomFilterArea({super.key, required this.appLocalization});

  @override
  State<CustomFilterArea> createState() => _CustomFilterAreaState();
}

class _CustomFilterAreaState extends State<CustomFilterArea> {
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    fromDate = DateTime(fromDate.year, fromDate.month, fromDate.day);
    toDate = DateTime(toDate.year, toDate.month, toDate.day);
  }

  Future<void> _selectDate(bool isFrom) async {
    final DateTime initialDate = isFrom ? (fromDate) : (toDate);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
          if (fromDate.isAfter(toDate)) {
            toDate = fromDate;
          }
        } else {
          toDate = picked;
          if (toDate.isBefore(fromDate)) {
            fromDate = toDate;
          }
        }
      });
    }
  }

  Widget _buildDateBox(
      String label, DateTime? date, bool isFrom, double scale) {
    return GestureDetector(
      onTap: () => _selectDate(isFrom),
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
                          style: const TextStyle(
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
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 300) {
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
              return Row(
                children: [
                  Expanded(
                    child: _buildDateBox(
                        widget.appLocalization.getLocalizedString('dateFrom'),
                        fromDate,
                        true,
                        scale),
                  ),
                  const SizedBox(
                    height: 40,
                    child: VerticalDivider(
                      color: AppColors.hintTextColor,
                      thickness: 1.0,
                      width: 20,
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
                        color: AppColors.secondaryColor,
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

    String fromDateStr = DateHelper.formatDateOnly(fromDate);
    String toDateStr = DateHelper.formatDateOnly(toDate);
    showLoadingAvatar(context);
    try {
      List<CartModel> historyCarts =
          await CartService.fetchCarts(context, fromDateStr, toDateStr);
      HistoryCartState historyCartState =
          Provider.of<HistoryCartState>(context, listen: false);
      historyCartState.carts = historyCarts;
      Navigator.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch carts: $e')),
      );
    }
  }
}

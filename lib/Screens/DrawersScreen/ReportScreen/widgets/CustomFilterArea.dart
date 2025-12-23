import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../Constants/app_color.dart';
import '../../../../services/LocalizationService.dart';

class CustomFilterArea extends StatefulWidget {
  final LocalizationService appLocalization;
  final Function(DateTime, DateTime) onDateRangeSelected; // Add this callback

  const CustomFilterArea({
    Key? key,
    required this.appLocalization,
    required this.onDateRangeSelected, // Add the callback parameter
  }) : super(key: key);

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
      widget.onDateRangeSelected(
          fromDate, toDate); // Pass the selected dates back to ReportScreen
    }
  }

  Widget _buildDateBox(String label, DateTime? date, bool isFrom) {
    return GestureDetector(
      onTap: () => _selectDate(isFrom), // Make the entire field tappable
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.secondaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.appLocalization
                        .getLocalizedString(isFrom ? 'dateFrom' : 'dateTo'),
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
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
                              color: Colors.black87),
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
                      true),
                  const SizedBox(height: 2),
                  _buildDateBox(
                      widget.appLocalization.getLocalizedString('dateTo'),
                      toDate,
                      false),
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
                    ),
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
}

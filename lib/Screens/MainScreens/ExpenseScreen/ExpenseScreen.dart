import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Constants/app_color.dart';
import '../../../Custom_Components/CustomLoadingAvatar.dart';
import '../../../api_services/expenses_service.dart';
import '../../../services/CheckConnectivity.dart';
import '../../../States/ExpenseState.dart';
import '../../LoginScreen/Custom_Widgets/CustomFailedPopup.dart';
import 'widgets/custom_dropdown.dart';
import 'widgets/custom_textfield.dart';
import 'widgets/custom_button.dart';
import '../../../Models/ExpensesItemModel.dart';
import '../../../Services/LocalizationService.dart';

class OtherSellScreen extends StatefulWidget {
  const OtherSellScreen({Key? key}) : super(key: key);

  @override
  State<OtherSellScreen> createState() => _OtherSellScreenState();
}

class _OtherSellScreenState extends State<OtherSellScreen> {
  final TextEditingController saleDetailsController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  ExpensesItemModel? selectedSaleType;
  List<ExpensesItemModel> expensesList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final expenseState = Provider.of<ExpenseState>(context, listen: false);
      final newExpenses = expenseState.expenses;
      expensesList = List.from(newExpenses);
    });
  }

  @override
  void dispose() {
    // Dispose controllers when screen is disposed
    saleDetailsController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization =
        Provider.of<LocalizationService>(context, listen: false);
    final expenseState = Provider.of<ExpenseState>(context, listen: false);
    final newExpenses = expenseState.expenses;
    expensesList = List.from(newExpenses);

    final double screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / 390).clamp(0.70, 1.2);
    final horizontalPadding = 20.0 * scale;
    final verticalSpacing = 10.0 * scale;
    final titleFontSize = 16.0 * scale;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2 * verticalSpacing),
                      Text(
                        appLocalization.getLocalizedString("expensesType"),
                        style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: verticalSpacing),
                      CustomDropdown(
                        expenses: expensesList.map((item) {
                          return {
                            "id": item.id.toString(),
                            "name": item.name,
                          };
                        }).toList(),
                        selectedValue: selectedSaleType?.id.toString(),
                        onChanged: (newId) {
                          setState(() {
                            selectedSaleType = expensesList.firstWhere((item) =>
                                item.id.toString() == newId.toString());
                          });
                          if (selectedSaleType != null &&
                              selectedSaleType!.name.toLowerCase() != 'other' &&
                              selectedSaleType!.name.toLowerCase() != 'others')
                            priceController.text =
                                selectedSaleType?.price.toString() ?? '';
                          else if (selectedSaleType!.name.toLowerCase() !=
                                  'other' ||
                              selectedSaleType!.name.toLowerCase() != 'others')
                            priceController.text = '';
                        },
                      ),
                      SizedBox(height: 2 * verticalSpacing),
                      Text(
                        appLocalization.getLocalizedString("description"),
                        style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: verticalSpacing),
                      CustomTextField(
                        controller: saleDetailsController,
                        labelText:
                            appLocalization.getLocalizedString("expenseDetail"),
                        maxLines: 4,
                      ),
                      SizedBox(height: 2 * verticalSpacing),
                      Text(
                        appLocalization.getLocalizedString("price"),
                        style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: verticalSpacing),
                      CustomTextField(
                        controller: priceController,
                        labelText: appLocalization.getLocalizedString("price"),
                        prefixIcon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 2 * verticalSpacing),
                      const Spacer(), // Pushes the button to the bottom
                      CustomButton(
                        text: appLocalization.getLocalizedString("submit"),
                        onPressed: () async {
                          bool isConnected = await checkConnectivity();
                          if (!isConnected) {
                            showLoginFailedDialog(
                              context,
                              appLocalization
                                  .getLocalizedString('noInternetConnection'),
                              appLocalization.getLocalizedString('noInternet'),
                              appLocalization.selectedLanguageCode,
                              appLocalization.getLocalizedString('ok'),
                            );
                            return;
                          }
                          _checkoutExpense(appLocalization);
                        },
                        color: AppColors.primaryColor,
                      ),
                      SizedBox(height: 2 * verticalSpacing),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _checkoutExpense(LocalizationService appLocalization) async {
    final saleDetails = saleDetailsController.text;
    print("ffff : ${priceController.text}");

    final price = (double.tryParse(priceController.text) ?? 0.0).toInt();
    print("ffff2 : ${price}");

    // Validate input
    if (selectedSaleType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(appLocalization.getLocalizedString("mandatoryExpenseType")),
          backgroundColor: Color(0xFFD32F2F), // Red background for failure
        ),
      );
      return;
    } else if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalization.getLocalizedString("priceValidValue")),
          backgroundColor: Color(0xFFD32F2F), // Red background for failure
        ),
      );
      return; // Exit the function early
    } else if (saleDetails.isEmpty &&
        (selectedSaleType!.name.toLowerCase() == 'other' ||
            selectedSaleType!.name.toLowerCase() == 'others')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(appLocalization.getLocalizedString("descriptionMandatory")),
          backgroundColor: Color(0xFFD32F2F), // Red background for failure
        ),
      );
      return;
    }
    try {
      showLoadingAvatar(context);
      // Call the service to create the expense order
      bool success = await ExpensesService.createExpenseOrder(
          context, selectedSaleType!.id, saleDetails, price);

      if (success) {
        // If successful, show success snackbar with custom background color
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appLocalization.getLocalizedString("expenseCreatedSuccessfully"),
            ),
            backgroundColor: Color(0xFF4CAF50), // Green background for success
          ),
        );
        // Clear all text fields if the expense was created successfully
        saleDetailsController.clear();
        priceController.clear();
        setState(() {
          selectedSaleType = null; // Reset selected sale type to null
        });
      } else {
        // Handle case where the service failed, show failure snackbar with custom background color
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appLocalization.getLocalizedString("expenseCreationFailed"),
            ),
            backgroundColor: Color(0xFFD32F2F), // Red background for failure
          ),
        );
      }
    } catch (e) {
      // Catch any exceptions and show an error snackbar
      debugPrint("Error occurred: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              appLocalization.getLocalizedString("unexpectedErrorOccurred")),
          backgroundColor: Color(0xFFD32F2F), // Red background for failure
        ),
      );
    } finally {
      Navigator.of(context)
          .pop(); // Close loading regardless of success or failure
    }
  }
}

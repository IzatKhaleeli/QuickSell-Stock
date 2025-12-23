import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_sell/screens/MainScreens/CartScreen/widgets/payment_method_popup.dart';
import '../../../Constants/app_color.dart';
import '../../../Custom_Components/CustomLoadingAvatar.dart';
import '../../../Custom_Components/CustomPopups.dart';
import '../../../services/LocalizationService.dart';
import '../../../api_services/CartService.dart';
import '../../../services/CheckConnectivity.dart';
import '../../../States/CartState.dart';
import '../../LoginScreen/Custom_Widgets/CustomFailedPopup.dart';
import '../../MainScreen.dart';
import 'widgets/cart_item.dart';
import 'widgets/checkout_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var appLocalization =
        Provider.of<LocalizationService>(context, listen: false);
    final screenSize = MediaQuery.of(context).size;
    final scale = (screenSize.width / 390).clamp(0.70, 1.2);
    final scale2 = (screenSize.width / 390).clamp(0.70, double.infinity);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.0 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Consumer<CartState>(
                  builder: (context, cartState, child) {
                    if (cartState.itemsList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80 * scale,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16 * scale),
                            Text(
                              appLocalization.getLocalizedString("emptyCart"),
                              style: TextStyle(
                                fontSize: 18 * scale,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 390 * scale2,
                        child: Column(
                          children: [
                            Table(
                              columnWidths: {
                                0: FlexColumnWidth(1.5),
                                1: FlexColumnWidth(1),
                                2: FlexColumnWidth(1),
                                3: FlexColumnWidth(2),
                              },
                              children: [
                                TableRow(
                                  children: [
                                    _buildTableHeaderCell(
                                        appLocalization
                                            .getLocalizedString("name"),
                                        scale),
                                    _buildTableHeaderCell(
                                        appLocalization
                                            .getLocalizedString("sellingPrice"),
                                        scale),
                                    _buildTableHeaderCell(
                                        appLocalization
                                            .getLocalizedString("actualPrice"),
                                        scale),
                                    _buildTableHeaderCell(
                                        appLocalization
                                            .getLocalizedString("actions"),
                                        scale),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            // Scrollable item list
                            Expanded(
                              child: ListView.builder(
                                itemCount: cartState.itemsList.length,
                                itemBuilder: (context, index) {
                                  final item = cartState.itemsList[index];
                                  return CartItem(
                                    item: item,
                                    isLastItem:
                                        index == cartState.itemsList.length - 1,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Consumer<CartState>(
                builder: (context, cartState, child) {
                  if (cartState.itemsList.isEmpty)
                    return const SizedBox(); // Hide total when empty
                  return Column(
                    children: [
                      const Divider(),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${appLocalization.getLocalizedString("totalPrice")}: ${cartState.totalPrice}',
                            style: TextStyle(
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: cartState.selectedItemId != null
                                  ? const Color(0xFFFF7043)
                                  : Colors.grey,
                              size: 24 * scale,
                            ),
                            onPressed: cartState.selectedItemId != null
                                ? () {
                                    CustomPopups.showCustomDialog(
                                      context: context,
                                      icon: const Icon(Icons.warning,
                                          color: Color(0xFFFF7043)),
                                      title: appLocalization.getLocalizedString(
                                          "deleteConfirmationTitle"),
                                      message:
                                          appLocalization.getLocalizedString(
                                              "deleteConfirmationBody"),
                                      deleteButtonText: appLocalization
                                          .getLocalizedString("delete"),
                                      onPressButton: () {
                                        // Clear the cart on confirmation
                                        cartState.deleteItemCart(
                                            cartState.selectedItemId!);
                                      },
                                    );
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Consumer<CartState>(
                builder: (context, cartState, child) {
                  return cartState.itemsList.isNotEmpty
                      ? Center(
                          child: SizedBox(
                            width: screenSize.width * 0.85,
                            child: CheckoutButton(
                              onPressed: () async {
                                bool isConnected = await checkConnectivity();
                                if (!isConnected) {
                                  showLoginFailedDialog(
                                    context,
                                    appLocalization.getLocalizedString(
                                        'noInternetConnection'),
                                    appLocalization
                                        .getLocalizedString('noInternet'),
                                    appLocalization.selectedLanguageCode,
                                    appLocalization.getLocalizedString('ok'),
                                  );
                                  return;
                                }
                                final rootContext = context;
                                _showPaymentPopup(rootContext,
                                    cartState.totalPrice, appLocalization);
                              },
                            ),
                          ),
                        )
                      : const SizedBox(); // Hide checkout button when empty
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeaderCell(String text, double scale) {
    return Padding(
      padding: EdgeInsets.all(4.0 * scale),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void _showPaymentPopup(BuildContext rootContext, double total,
      LocalizationService localizationService) {
    showDialog(
      context: rootContext,
      builder: (dialogContext) {
        return PaymentMethodPopup(
          total: total,
          onSubmit: (method, cash, visa) async {
            print("Chosen method: $method");
            print("Cash: $cash, Visa: $visa");
            // Proceed with checkout
            await _checkout(rootContext, localizationService, cash, visa);
          },
        );
      },
    );
  }

  Future<void> _checkout(
      BuildContext context,
      LocalizationService localizationService,
      double totalCash,
      double totalVisa) async {
    showLoadingAvatar(context);
    final cartState = Provider.of<CartState>(context, listen: false);

    try {
      await CartService.createOrder(
          context, cartState.itemsList, totalCash, totalVisa);

      Navigator.of(context).pop();
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "${localizationService.getLocalizedString("createOrderSuccess")}"),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );

      cartState.clearState();

      Navigator.of(context).pushReplacement(
        _createRoute(
            MainScreen()), // Navigate to DashboardScreen on successful login
      );
    } catch (e) {
      print("Error _checkout:${e}");
      if (!context.mounted) return;
      Navigator.of(context).pop();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "${localizationService.getLocalizedString("createOrderFailed")}:${e}"),
          backgroundColor: Color(0xFFD32F2F), // Custom red shade
        ),
      );
    }
  }

  Route _createRoute(Widget destination) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.slowMiddle;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var fadeAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: fadeAnimation,
          child: child,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../Constants/app_color.dart';
import '../Services/LocalizationService.dart';
import '../services/responsive.dart';
import 'DrawersScreen/app_drawer.dart';
import 'MainScreens/CartScreen/CartScreen.dart';
import 'MainScreens/ExpenseScreen/ExpenseScreen.dart';
import 'MainScreens/StoreSellScreen/StoreSellScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      StoreSellScreen(),
      const OtherSellScreen(),
      const CartScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalization =
        Provider.of<LocalizationService>(context, listen: false);
    final responsive = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalization.getLocalizedString("main_screen"),
          style: TextStyle(fontSize: responsive.scale(18)),
        ),
        backgroundColor: AppColors.cardBackgroundColor,
        elevation: 0,
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      drawer: const AppDrawer(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.primaryTextColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          backgroundColor: AppColors.cardBackgroundColor,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(FontAwesomeIcons.store, size: 18),
              label: appLocalization.getLocalizedString("sales"),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.sell, size: 18),
              label: appLocalization.getLocalizedString("expenses"),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart, size: 18),
              label: appLocalization.getLocalizedString("cart"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Constants/app_color.dart';
import '../../Constants/app_routeTransition.dart';
import '../../Custom_Components/CustomLoadingAvatar.dart';
import '../../Custom_Components/CustomPopups.dart';
import '../../Services/LocalizationService.dart';
import '../../States/LoginState.dart';
import 'CartHistoryScreen/CartHistoryScreen.dart';
import 'ReportScreen/ReportScreen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<String?> _getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  @override
  Widget build(BuildContext context) {
    final appLocalization =
        Provider.of<LocalizationService>(context, listen: false);
    final screenSize = MediaQuery.of(context).size;
    final scale = (screenSize.width / 390).clamp(0.8, 1.2);
    final drawerWidth = (screenSize.width * 0.8).clamp(250.0, 320.0);

    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        child: FutureBuilder<String?>(
          future: _getUserName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  appLocalization.getLocalizedString("errorLoadingData"),
                  style: const TextStyle(fontSize: 13),
                ),
              );
            } else if (snapshot.hasData) {
              final userName = snapshot.data;
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text("   $userName"),
                    accountEmail: const Text(""),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: AppColors.backgroundColor,
                      child: Icon(Icons.person,
                          size: 50 * scale, color: Colors.black),
                    ),
                    decoration:
                        const BoxDecoration(color: AppColors.primaryColor),
                  ),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title:
                        Text(appLocalization.getLocalizedString("historyCart")),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        AppRouteTransition(page: CartHistoryScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bar_chart),
                    title: Text(appLocalization.getLocalizedString("report")),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        AppRouteTransition(page: ReportScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(
                        appLocalization.getLocalizedString("changeLanguage")),
                    onTap: () async {
                      showLoadingAvatar(context);
                      await Future.delayed(const Duration(seconds: 1));
                      String currentLang = appLocalization.selectedLanguageCode;
                      String newLang = currentLang == 'en' ? 'ar' : 'en';
                      appLocalization.selectedLanguageCode = newLang;
                      Navigator.popUntil(context, (route) => false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SizedBox()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(appLocalization.getLocalizedString("about")),
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            title: Center(
                              child: Text(
                                appLocalization.getLocalizedString("about"),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            content: const Directionality(
                              textDirection: TextDirection.ltr,
                              child: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text(
                                      'App Name:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 8.0, bottom: 12),
                                      child: Text(
                                        'Quick Sell',
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 13),
                                      ),
                                    ),
                                    Text(
                                      'Store:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 8.0, bottom: 12),
                                      child: Text(
                                        'GE',
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 13),
                                      ),
                                    ),
                                    Text(
                                      'Version:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        '1.0.0',
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text(
                                  'Close',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: Text(appLocalization.getLocalizedString("logout")),
                    onTap: () {
                      CustomPopups.showCustomDialog(
                        context: context,
                        icon: const Icon(Icons.exit_to_app,
                            size: 40, color: AppColors.secondaryColor),
                        title: appLocalization
                            .getLocalizedString("logoutConfirmationTitle"),
                        message: appLocalization
                            .getLocalizedString("logoutConfirmationBody"),
                        deleteButtonText:
                            appLocalization.getLocalizedString("logout"),
                        onPressButton: () {
                          showLoadingAvatar(context);

                          Future.delayed(const Duration(milliseconds: 1000),
                              () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Provider.of<LoginState>(context, listen: false)
                                .logout(context);
                          });
                        },
                      );
                    },
                  ),
                ],
              );
            } else {
              return Center(
                  child: Text(
                      appLocalization.getLocalizedString("noDataAvailable"),
                      style: const TextStyle(fontSize: 13)));
            }
          },
        ),
      ),
    );
  }
}

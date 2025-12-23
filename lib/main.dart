import 'package:flutter/services.dart';
import '../States/LoginState.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/LocalizationService.dart';
import 'screens/SplashScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import './Constants/app_color.dart';
import 'States/ExpenseState.dart';
import 'States/CartState.dart';
import 'States/HistoryCartState.dart';
import 'States/HistoryExpenseState.dart';
import 'States/ItemsState.dart';
import 'States/StoreState.dart';
import 'globalErrorListener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  LocalizationService localizeService = LocalizationService();
  bool isJailbroken = false;
  bool developerMode = false;
  try {
    isJailbroken = await FlutterJailbreakDetection.jailbroken;
    developerMode = await FlutterJailbreakDetection.developerMode;
    print("developer mode :${developerMode} : isJailbroken :${isJailbroken}");
  } on PlatformException {
    isJailbroken = true;
    developerMode = true;
  } catch (e) {
    print("Error localization Jailbroken: $e");
  }

  if (isJailbroken) {
    runApp(const MyApp(isJailbroken: true));
  } else {
    try {
      await localizeService.initLocalization();
    } catch (e) {
      print("Error initializing localization: $e");
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => LocalizationService()),
          ChangeNotifierProvider(create: (context) => LoginState()),
          ChangeNotifierProvider(create: (context) => CartState()),
          ChangeNotifierProvider(create: (context) => ExpenseState()),
          ChangeNotifierProvider(create: (context) => ItemsState()),
          ChangeNotifierProvider(create: (context) => StoresState()),
          ChangeNotifierProvider(create: (context) => HistoryCartState()),
          ChangeNotifierProvider(create: (context) => HistoryExpenseState()),
        ],
        child: const MyApp(isJailbroken: false),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final bool isJailbroken;

  const MyApp({super.key, required this.isJailbroken});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      colorScheme: const ColorScheme.light().copyWith(
        primary: AppColors.primaryColor,
        onPrimary: AppColors.primaryColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.secondaryColor,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: AppColors.primaryColor.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
      ),
      textTheme: const TextTheme(
        titleMedium: TextStyle(
            color: AppColors.primaryColor, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: AppColors.primaryTextColor),
      ),
    );

    if (isJailbroken) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'This application cannot be run on jailbroken devices.',
              style: TextStyle(color: Colors.red, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Consumer<LocalizationService>(
        builder: (context, localizeService, _) {
      return GlobalErrorListener(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'QuickSell',
          theme: theme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ar', 'AE'),
          ],
          locale: Locale(localizeService.selectedLanguageCode),
          home: const SplashScreen(),
          builder: (context, child) {
            return Directionality(
              textDirection: localizeService.selectedLanguageCode == 'en'
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              child: child!,
            );
          },
        ),
      );
    });
  }
}

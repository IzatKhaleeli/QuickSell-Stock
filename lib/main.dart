import 'package:flutter/services.dart';
import '../States/LoginState.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Services/LocalizationService.dart';
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
    // Check for jailbreak status
    isJailbroken = await FlutterJailbreakDetection.jailbroken;
    developerMode = await FlutterJailbreakDetection.developerMode;
    print("developer mode :${developerMode} : isJailbroken :${isJailbroken}");
  } on PlatformException {
    isJailbroken = true;
    developerMode = true;
  } catch (e) {
    print("Error localization Jailbroken: $e");
    // Handle initialization error as needed
  }

  if (isJailbroken) {
    runApp(MyApp(isJailbroken: true));
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
      primaryColor: AppColors.primaryColor, // Use AppColors
      scaffoldBackgroundColor: AppColors.backgroundColor, // Use AppColors
      colorScheme: ColorScheme.light().copyWith(
        primary: AppColors.primaryColor, // Use AppColors
        onPrimary: AppColors.primaryColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.secondaryColor, // Use AppColors
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: AppColors.primaryColor.withOpacity(0.5),
              width: 1), // Use AppColors
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: AppColors.primaryColor, width: 2), // Use AppColors
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor, // Use AppColors
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primaryColor, // Use AppColors
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
      ),
      textTheme: TextTheme(
        titleMedium: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold), // Use AppColors
        bodyMedium:
            TextStyle(color: AppColors.primaryTextColor), // Use AppColors
      ),
    );

    if (isJailbroken) {
      return MaterialApp(
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
          title: 'QuickSell', // App title
          theme: theme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'), // English
            Locale('ar', 'AE'), // Arabic
            // Add more locales as needed
          ],
          locale: Locale(localizeService.selectedLanguageCode),
          home: SplashScreen(),
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

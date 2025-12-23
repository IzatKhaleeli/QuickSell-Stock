import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../../Constants/app_color.dart';
import '../../Models/StoreModel.dart';
import '../../services/LocalizationService.dart';
import '../../services/CheckConnectivity.dart';
import '../../States/ExpenseState.dart';
import '../../States/ItemsState.dart';
import '../../States/StoreState.dart';
import 'Custom_Widgets/CustomButton.dart';
import 'Custom_Widgets/CustomDropDownLanguage.dart';
import 'Custom_Widgets/CustomFailedPopup.dart';
import '../../Custom_Components/CustomLoadingAvatar.dart';
import 'Custom_Widgets/CustomTextField.dart';
import '../../States/LoginState.dart';
import '../../services/secure_storage.dart';
import '../MainScreen.dart';
import 'dart:async';
import 'Custom_Widgets/LogoWidget.dart';
import 'Custom_Widgets/SmartLoginButton.dart';

class LoginScreen extends StatefulWidget {
  static const List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'العربية', 'code': 'ar'},
  ];
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  StoreModel selectedStore = StoreModel(storeId: '1', address: 'test');
  bool _isSmartLoginSupported = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _checkSmartLoginSupport();
    });
  }

  Future<void> _checkSmartLoginSupport() async {
    final auth = LocalAuthentication();
    bool canCheckBiometrics = await auth.isDeviceSupported();
    List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();
    print(availableBiometrics);
    if (canCheckBiometrics && availableBiometrics.isNotEmpty) {
      if (availableBiometrics.contains(BiometricType.face) ||
          availableBiometrics.contains(BiometricType.fingerprint) ||
          availableBiometrics.contains(BiometricType.weak)) {
        setState(() {
          _isSmartLoginSupported = true;
        });
      }
    }
  }

  bool validateLoginInputs(LoginState loginState) {
    String username = loginState.username;
    String password = loginState.password;

    if (username.isEmpty || password.isEmpty || selectedStore.storeId.isEmpty) {
      return false;
    }

    return true;
  }

  bool validateStoreInputs() {
    if (selectedStore.storeId.isEmpty) {
      return false;
    }
    return true;
  }

  void _handleSmartLogin(BuildContext context, LoginState loginState,
      LocalizationService localizationService, StoreModel? store) async {
    late final LocalAuthentication auth;
    auth = LocalAuthentication();
    bool isSupported = await auth.isDeviceSupported();
    if (!isSupported) {
      showLoginFailedDialog(
        context,
        localizationService.getLocalizedString('noBiometricSupportBody'),
        localizationService.isLocalizationLoaded
            ? localizationService.getLocalizedString('loginFailed')
            : "Biometric not supported",
        localizationService.selectedLanguageCode,
        localizationService.getLocalizedString('ok'),
      );
      return;
    }

    try {
      bool isSmart = true;
      List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();
      String localizedReason = 'Scan to login';
      // Check for Face ID or Fingerprint biometrics
      if (availableBiometrics.contains(BiometricType.face) ||
          availableBiometrics.contains(BiometricType.weak)) {
        localizedReason = 'Scan your face to login';
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        localizedReason = 'Scan your finger to login';
      } else
        isSmart = false;

      bool authenticated = false;
      if (isSmart) {
        print("is smart started");
        authenticated = await auth.authenticate(
          localizedReason: localizedReason,
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );
      }
      if (authenticated) {
        Map<String, String?> credentials = await getCredentials();
        String? username = credentials['username'];
        String? password = credentials['password'];
        if (username != null && password != null) {
          loginState.setPassword(password);
          loginState.setUsername(username);
          handleLogin(context, localizationService, loginState, store);
        } else {
          showLoginFailedDialog(
            context,
            localizationService.getLocalizedString('WrongCredentialsFoundBody'),
            localizationService.isLocalizationLoaded
                ? localizationService.getLocalizedString('loginfailed')
                : "Login Failed",
            localizationService.selectedLanguageCode,
            localizationService.getLocalizedString('ok'),
          );
        }
      }
    } on PlatformException catch (e) {
      print("e:${e}");
      showLoginFailedDialog(
        context,
        "${localizationService.getLocalizedString('loginfailedUnexpected')}",
        localizationService.isLocalizationLoaded
            ? localizationService.getLocalizedString('loginfailed')
            : "Login Failed",
        localizationService.selectedLanguageCode,
        localizationService.getLocalizedString('ok'),
      );
    }
  }

  Future<void> handleLogin(
      BuildContext context,
      LocalizationService localizationService,
      LoginState loginState,
      StoreModel? selectedStore) async {
    showLoadingAvatar(context);

    try {
      var loginResult = await loginState.login(
          loginState.username, loginState.password, context);

      if (loginResult["status"] == 200) {
        await saveCredentials(loginState.username, loginState.password);

        int storeIdInt = 1;

        await Provider.of<ExpenseState>(context, listen: false)
            .fetchExpenses(context);
        await Provider.of<ItemsState>(context, listen: false)
            .fetchItems(context, storeIdInt);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (Route<dynamic> route) => false,
        );
      } else if (loginResult["status"] == 400) {
        Navigator.pop(context);
        showLoginFailedDialog(
          context,
          localizationService.getLocalizedString('loginFailedwrong'),
          localizationService.getLocalizedString('loginfailed'),
          localizationService.selectedLanguageCode,
          localizationService.getLocalizedString('ok'),
        );
      } else {
        Navigator.pop(context);
        showLoginFailedDialog(
          context,
          localizationService.getLocalizedString('loginFailedwrong'),
          loginResult["error"],
          localizationService.selectedLanguageCode,
          localizationService.getLocalizedString('ok'),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      showLoginFailedDialog(
        context,
        localizationService.getLocalizedString('loginfailedUnexpected'),
        localizationService.getLocalizedString('loginfailed'),
        localizationService.selectedLanguageCode,
        localizationService.getLocalizedString('ok'),
      );
      print("loading failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    double maxWidth =
        ScreenUtil().screenWidth > 600 ? 600.w : ScreenUtil().screenWidth * 0.9;
    final screenSize = MediaQuery.of(context).size;

    final scale = (screenSize.width / 390).clamp(0.85, 1.2);
    final verticalPadding = 12.0 * scale;
    final horizontalPadding = screenSize.width * 0.07;
    final spacingLarge = 20.0 * scale;
    final spacingMedium = 17.0 * scale;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocalizationService>(
          create: (_) {
            var localizationState = LocalizationService();
            localizationState.initLocalization();
            return localizationState;
          },
        ),
        ChangeNotifierProvider<LoginState>(
          create: (_) => LoginState(),
        ),
      ],
      child: Consumer2<LocalizationService, LoginState>(
        builder: (context, localizationService, loginState, _) {
          return Directionality(
            textDirection: localizationService.selectedLanguageCode == "ar"
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.primaryColor,
                elevation: 0,
                actions: [
                  CustomDropDown(localizationService: localizationService),
                ],
              ),
              body: SafeArea(
                child: Container(
                  color: AppColors.backgroundColor,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      vertical: verticalPadding,
                      horizontal: horizontalPadding,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const LogoWidget(),
                            SizedBox(height: spacingLarge),
                            CustomTextField(
                              hint: localizationService.isLocalizationLoaded
                                  ? localizationService
                                      .getLocalizedString('userName')
                                  : 'Username',
                              icon: Icons.person_outline,
                              onChanged: loginState.setUsername,
                              textColor: AppColors
                                  .primaryTextColor, // Pass the primary text color
                              hintColor: AppColors
                                  .hintTextColor, // Pass the hint text color
                              iconColor:
                                  AppColors.iconColor, // Pass the icon color
                              borderColor: AppColors
                                  .borderColor, // Pass the border color
                              fillColor: AppColors
                                  .cardBackgroundColor, // Pass the fill color
                              backgroundColor: AppColors
                                  .backgroundColor, // Pass the background color
                            ),
                            SizedBox(height: spacingMedium),
                            CustomTextField(
                              hint: localizationService.isLocalizationLoaded
                                  ? localizationService
                                      .getLocalizedString('password')
                                  : 'Password',
                              icon: Icons.lock_outline,
                              obscureText: true,
                              onChanged: loginState.setPassword,
                              textColor: AppColors
                                  .primaryTextColor, // Pass the primary text color
                              hintColor: AppColors
                                  .hintTextColor, // Pass the hint text color
                              iconColor:
                                  AppColors.iconColor, // Pass the icon color
                              borderColor: AppColors
                                  .borderColor, // Pass the border color
                              fillColor: AppColors
                                  .cardBackgroundColor, // Pass the fill color
                              backgroundColor: AppColors
                                  .backgroundColor, // Pass the background color
                            ),
                            SizedBox(height: spacingLarge),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: screenSize.height * 0.1),
                                child: CustomButton(
                                  text: localizationService.isLocalizationLoaded
                                      ? localizationService
                                          .getLocalizedString('login')
                                      : 'Login',
                                  onPressed: () async {
                                    bool isConnected =
                                        await checkConnectivity();
                                    if (!isConnected) {
                                      showLoginFailedDialog(
                                        context,
                                        localizationService.getLocalizedString(
                                            'noInternetConnection'),
                                        localizationService
                                            .getLocalizedString('noInternet'),
                                        localizationService
                                            .selectedLanguageCode,
                                        localizationService
                                            .getLocalizedString('ok'),
                                      );
                                      return;
                                    }
                                    // Validate login inputs
                                    bool isValid =
                                        validateLoginInputs(loginState);
                                    if (!isValid) {
                                      showLoginFailedDialog(
                                        context,
                                        localizationService.getLocalizedString(
                                            'loginFailedEmpty'),
                                        localizationService
                                            .getLocalizedString('loginfailed'),
                                        localizationService
                                            .selectedLanguageCode,
                                        localizationService
                                            .getLocalizedString('ok'),
                                      );
                                      return;
                                    }
                                    // Handle login process and navigation
                                    await handleLogin(
                                        context,
                                        localizationService,
                                        loginState,
                                        selectedStore);
                                  },
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                            if (_isSmartLoginSupported)
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: screenSize.height *
                                          0.01), // Adjust padding if needed
                                  child: SmartLoginButton(
                                    onPressed: () async {
                                      // Check for internet connectivity
                                      bool isConnected =
                                          await checkConnectivity();
                                      if (!isConnected) {
                                        showLoginFailedDialog(
                                          context,
                                          localizationService
                                              .getLocalizedString('noInternet'),
                                          localizationService
                                              .getLocalizedString(
                                                  'noInternetConnection'),
                                          localizationService
                                              .selectedLanguageCode,
                                          localizationService
                                              .getLocalizedString('ok'),
                                        );
                                        return;
                                      }
                                      // Validate login inputs
                                      bool isValid = validateStoreInputs();
                                      if (!isValid) {
                                        showLoginFailedDialog(
                                          context,
                                          localizationService
                                              .getLocalizedString(
                                                  'loginFailedStoreEmpty'),
                                          localizationService
                                              .getLocalizedString(
                                                  'loginfailed'),
                                          localizationService
                                              .selectedLanguageCode,
                                          localizationService
                                              .getLocalizedString('ok'),
                                        );
                                        return;
                                      }
                                      _handleSmartLogin(context, loginState,
                                          localizationService, selectedStore);
                                    },
                                    buttonColor: AppColors
                                        .primaryColor, // Set button color to match login button
                                    iconColor: AppColors.backgroundColor,
                                    buttonWidth:
                                        150, // Customize the button width if needed
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

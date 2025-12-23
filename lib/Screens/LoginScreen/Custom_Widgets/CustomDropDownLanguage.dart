import 'package:flutter/material.dart';
import '../../../Constants/app_color.dart';
import '../../../services/LocalizationService.dart';
import '../LoginScreen.dart';

class CustomDropDown extends StatelessWidget {
  final LocalizationService localizationService;

  CustomDropDown({Key? key, required this.localizationService})
      : super(key: key);

  String getLanguageName(String code) {
    for (var language in LoginScreen.languages) {
      if (language['code'] == code) {
        return language['name']!;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / 390).clamp(0.70, 1.2);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0 * scale),
      child: GestureDetector(
        onTap: () {
          // Open the PopupMenu when the Row is tapped
          final dynamic state = context.findRenderObject();
          state.showButtonMenu();
        },
        child: PopupMenuButton<String>(
          onSelected: (String newValue) {
            localizationService.selectedLanguageCode = newValue;
          },
          itemBuilder: (BuildContext context) {
            return LoginScreen.languages.map((Map<String, String> language) {
              return PopupMenuItem<String>(
                value: language['code']!,
                child: ListTile(
                  title: Text(
                    language['name']!,
                    style: TextStyle(fontSize: 16.0 * scale),
                  ),
                ),
              );
            }).toList();
          },
          child: Row(
            children: [
              Icon(Icons.language,
                  color: AppColors.cardBackgroundColor, size: 24.0 * scale),
              SizedBox(width: 8.0 * scale),
              Text(
                getLanguageName(localizationService.selectedLanguageCode),
                style: TextStyle(
                  color: AppColors.cardBackgroundColor,
                  fontSize: 16.0 * scale,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

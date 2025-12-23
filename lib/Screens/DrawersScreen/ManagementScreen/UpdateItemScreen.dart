import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/LocalizationService.dart';

class UpdateItemScreen extends StatelessWidget {
  const UpdateItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalization =
        Provider.of<LocalizationService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalization.getLocalizedString('updateItem')),
      ),
      body: Center(
        child: Text(
          appLocalization.getLocalizedString('updateItem'),
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

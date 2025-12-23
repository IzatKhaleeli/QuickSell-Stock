import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/LocalizationService.dart';

class NewItemScreen extends StatelessWidget {
  const NewItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalization =
        Provider.of<LocalizationService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalization.getLocalizedString('newItem')),
      ),
      body: Center(
        child: Text(
          appLocalization.getLocalizedString('newItem'),
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

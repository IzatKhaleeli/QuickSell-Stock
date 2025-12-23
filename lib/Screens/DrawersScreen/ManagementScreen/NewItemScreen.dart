import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../States/ItemsState.dart';
import '../../../services/LocalizationService.dart';
import '../../../services/responsive.dart';
import '../../../Custom_Components/form_field_widget.dart';
import '../../../Custom_Components/action_button.dart';
import '../../../Custom_Components/CustomLoadingAvatar.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _purchasePriceController =
      TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalization =
        Provider.of<LocalizationService>(context, listen: false);
    final r = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalization.getLocalizedString('newItem')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: r.scale(16),
            vertical: r.scale(12),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormFieldWidget(
                  label: appLocalization.getLocalizedString('item_name'),
                  isRequired: true,
                  controller: _nameController,
                  enabled: true,
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: r.scale(12)),
                FormFieldWidget(
                  label: appLocalization.getLocalizedString('purchasePrice'),
                  isRequired: true,
                  controller: _purchasePriceController,
                  enabled: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
                SizedBox(height: r.scale(12)),
                FormFieldWidget(
                  label: appLocalization.getLocalizedString('sellingPrice'),
                  isRequired: true,
                  controller: _sellingPriceController,
                  enabled: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
                SizedBox(height: r.scale(20)),
                ActionButton(
                  text: appLocalization.getLocalizedString('submit'),
                  isPrimary: true,
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      FocusScope.of(context).unfocus();
                      final itemState =
                          Provider.of<ItemsState>(context, listen: false);

                      showLoadingAvatar(context);
                      try {
                        final name = _nameController.text.trim();
                        final purchase = double.tryParse(
                            _purchasePriceController.text.trim());
                        final selling = double.tryParse(
                            _sellingPriceController.text.trim());

                        if (purchase == null || selling == null) {
                          Navigator.of(context, rootNavigator: true).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                appLocalization
                                    .getLocalizedString('priceValidValue'),
                              ),
                            ),
                          );
                          return;
                        }

                        final prefs = await SharedPreferences.getInstance();
                        final token = prefs.getString('token') ?? '';

                        Map<String, String> headers = {
                          "Authorization": "Bearer $token",
                          "Content-Type": "application/json",
                        };

                        Map<String, dynamic> body = {
                          "Name": name,
                          "ActualPrice": purchase,
                          "Price": selling,
                          "StoreId": "1",
                          "IsActive": "true",
                        };

                        final err =
                            await itemState.postItem(context, body, headers);

                        if (mounted) {
                          Navigator.of(context, rootNavigator: true).pop();
                        }

                        if (err == null) {
                          await itemState.fetchItems(context, 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(appLocalization.getLocalizedString(
                                  'itemCreatedSuccessfully')),
                            ),
                          );
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(err),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

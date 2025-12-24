import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../Constants/app_color.dart';
import '../services/responsive.dart';
import '../Custom_Components/form_field_widget.dart';
import '../Custom_Components/action_button.dart';
import '../Models/ItemModel.dart';
import '../States/ItemsState.dart';
import '../services/LocalizationService.dart';
import '../Custom_Components/CustomLoadingAvatar.dart';

class EditItemDialog extends StatefulWidget {
  final ItemModel item;

  const EditItemDialog({super.key, required this.item});

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _purchaseController;
  late final TextEditingController _sellingController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.itemName ?? '');
    _purchaseController =
        TextEditingController(text: widget.item.purchasePrice.toString());
    _sellingController =
        TextEditingController(text: widget.item.sellingPrice.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purchaseController.dispose();
    _sellingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final appLocalization =
        Provider.of<LocalizationService>(context, listen: false);

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r.scale(12))),
      child: Padding(
        padding: EdgeInsets.all(r.scale(16)),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appLocalization.getLocalizedString('updateItem'),
                    style: TextStyle(
                      fontSize: r.font(16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        size: r.scale(20), color: AppColors.iconColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: r.scale(10)),
              FormFieldWidget(
                label: appLocalization.getLocalizedString('item_name'),
                isRequired: true,
                controller: _nameController,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: r.scale(10)),
              FormFieldWidget(
                label: appLocalization.getLocalizedString('purchasePrice'),
                isRequired: true,
                controller: _purchaseController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
              SizedBox(height: r.scale(10)),
              FormFieldWidget(
                label: appLocalization.getLocalizedString('sellingPrice'),
                isRequired: true,
                controller: _sellingController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
              SizedBox(height: r.scale(16)),
              ActionButton(
                text: appLocalization.getLocalizedString('submit'),
                onPressed: () async {
                  await _submitEdit(appLocalization);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitEdit(LocalizationService appLocalization) async {
    final itemsState = Provider.of<ItemsState>(context, listen: false);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final purchase = double.tryParse(_purchaseController.text.trim());
    final selling = double.tryParse(_sellingController.text.trim());

    if (purchase == null || selling == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            appLocalization.getLocalizedString('priceValidValue'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    final itemState = Provider.of<ItemsState>(context, listen: false);

    final updatedItem = {
      "Price": selling,
      "ActualPrice": purchase,
      "IsActive": true,
      "StoreId": 1,
      "ItemName": name,
    };
    showLoadingAvatar(context);

    try {
      final err = await itemState.updateItem(
        context,
        widget.item.itemId,
        updatedItem,
      );

      if (err == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              appLocalization.getLocalizedString('itemUpdatedSuccessfully'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
        if (mounted) {
          Navigator.of(context).pop();
        }
        await itemsState.fetchItems(context, 1);
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              err,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }
}

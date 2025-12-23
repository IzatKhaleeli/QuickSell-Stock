import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Models/ItemCartModel.dart';
import '../../../../Constants/app_color.dart';
import '../../../../services/LocalizationService.dart';
import '../../../../States/CartState.dart';
import 'custom_text_field.dart';
import '../../../../Models/ItemModel.dart';

class BottomSheetWidget extends StatefulWidget {
  final ItemModel item;
  const BottomSheetWidget({required this.item, Key? key}) : super(key: key);

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  final TextEditingController _quantityController =
      TextEditingController(text: '1');
  final TextEditingController _offerPriceController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _quantityController.dispose();
    _offerPriceController.dispose();
    super.dispose();
  }

  void _confirmSale() {
    final cartState = context.read<CartState>();

    if (_formKey.currentState?.validate() ?? false) {
      final soldItem = ItemCart(
        id: widget.item.itemId,
        quantity: int.tryParse(_quantityController.text) ?? 0,
        sellingPrice: _offerPriceController.text.isNotEmpty
            ? double.tryParse(_offerPriceController.text) ??
                widget.item.sellingPrice
            : widget.item.sellingPrice,
        purchasePrice: widget.item.purchasePrice,
        itemName: widget.item.itemName,
      );
      cartState.addStoreItem(soldItem);
      debugPrint("Cart State: ${cartState.itemsList}");
      debugPrint("Total Price: ${cartState.totalPrice}");
      Navigator.pop(context);
    }
    // }
  }

  void _discardSale() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization =
        Provider.of<LocalizationService>(context, listen: false);

    final screenWidth = MediaQuery.of(context).size.width;
    final baseWidth = 390.0;
    final scale = (screenWidth / baseWidth).clamp(0.70, 1.2);

    final fontSizeSmall = 14 * scale;
    final fontSizeMedium = 16 * scale;
    final spacing = 12 * scale;
    final buttonWidth = 120 * scale;
    final buttonHeight = 45 * scale;
    final borderRadius = 16 * scale;

    return Directionality(
      textDirection: appLocalization.selectedLanguageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.all(spacing),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(borderRadius),
              topRight: Radius.circular(borderRadius),
            ),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _discardSale,
                        color: AppColors.primaryColor,
                      ),
                      Spacer(),
                      Text(
                        appLocalization.getLocalizedString('confirmSellTitle'),
                        style: TextStyle(
                          fontSize: fontSizeMedium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: spacing),
                      Spacer(),
                    ],
                  ),
                  SizedBox(height: spacing),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${appLocalization.getLocalizedString('name')}: ${widget.item.itemName}',
                        style: TextStyle(
                          fontSize: fontSizeSmall,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${appLocalization.getLocalizedString('sellingPrice')}: ${widget.item.sellingPrice}',
                        style: TextStyle(
                          fontSize: fontSizeSmall,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${appLocalization.getLocalizedString('purchasePrice')}: ${widget.item.purchasePrice}',
                        style: TextStyle(
                          fontSize: fontSizeSmall,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing),
                  CustomTextField(
                    controller: _offerPriceController,
                    labelText: appLocalization.getLocalizedString('offerPrice'),
                    keyboardType: TextInputType.number,
                  ),
                  CustomTextField(
                    controller: _quantityController,
                    labelText: appLocalization.getLocalizedString('quantity'),
                    keyboardType: TextInputType.number,
                    required: true,
                  ),
                  // if(sizeError)...[
                  //   Text(
                  //     appLocalization.getLocalizedString('quantityExceedsAvailable'),
                  //     style:  TextStyle(
                  //       color: AppColors.errorColor,
                  //       fontWeight: FontWeight.bold,
                  //       fontSize: fontSizeSmall,
                  //     ),
                  //   ),
                  //   SizedBox(height: spacing),
                  // ],
                  // FutureBuilder<List<ItemSizeModel>>(
                  //   future: _itemSizesFuture,
                  //   builder: (context, snapshot) {
                  //     if (snapshot.connectionState == ConnectionState.waiting) {
                  //       return Center(child: CircularProgressIndicator());
                  //     } else if (snapshot.hasError) {
                  //       return Text(appLocalization.getLocalizedString('errorLoading'));
                  //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  //       return Text(appLocalization.getLocalizedString('noSizesAvailable'));
                  //     }
                  //     else {
                  //       final sizes = snapshot.data!;
                  //       _selectedSize ??= sizes.first;
                  //
                  //       return Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           SizedBox(height: spacing),
                  //           Theme(
                  //             data: Theme.of(context).copyWith(
                  //               canvasColor: Colors.grey[200],
                  //               highlightColor: Colors.transparent,
                  //               splashColor: Colors.transparent,
                  //             ),
                  //             child: DropdownButtonFormField<ItemSizeModel>(
                  //               value: _selectedSize,
                  //               decoration: InputDecoration(
                  //                 filled: true,
                  //                 fillColor: AppColors.cardBackgroundColor,
                  //                 border: OutlineInputBorder(),
                  //                 contentPadding: EdgeInsets.symmetric(
                  //                   horizontal: spacing,
                  //                   vertical: 10,
                  //                 ),
                  //               ),
                  //               dropdownColor: Colors.white,
                  //               items: sizes.map((size) {
                  //                 return DropdownMenuItem<ItemSizeModel>(
                  //                   value: size,
                  //                   child: Text(
                  //                     '${size.sizeLabel} - ${appLocalization.getLocalizedString('quantity')}: ${size.quantity}',
                  //                     style: TextStyle(fontSize: fontSizeSmall),
                  //                   ),
                  //                 );
                  //               }).toList(),
                  //               onChanged: (value) {
                  //                 setState(() {
                  //                   _selectedSize = value;
                  //                 });
                  //               },
                  //               validator: (value) {
                  //                 if (value == null) {
                  //                   return appLocalization.getLocalizedString('pleaseChooseSize');
                  //                 }
                  //                 return null;
                  //               },
                  //             ),
                  //           ),
                  //           SizedBox(height: spacing),
                  //         ],
                  //       );
                  //     }
                  //   },
                  // ),
                  Center(
                    child: ElevatedButton(
                      onPressed: _confirmSale,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        minimumSize: Size(buttonWidth, buttonHeight),
                      ),
                      child: Text(
                        appLocalization.getLocalizedString('confirmSale'),
                        style: TextStyle(color: AppColors.lighterTextColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Constants/app_color.dart';
import '../../../services/LocalizationService.dart';
import '../../../services/responsive.dart';
import '../../../States/ItemsState.dart';
import '../../../Custom_Components/ItemCard.dart';
import '../../../Custom_Components/CustomPopups.dart';
import '../../../Custom_Components/CustomLoadingAvatar.dart';
import '../../../Custom_Components/EditItemDialog.dart';

class UpdateItemScreen extends StatefulWidget {
  const UpdateItemScreen({super.key});

  @override
  State<UpdateItemScreen> createState() => _UpdateItemScreenState();
}

class _UpdateItemScreenState extends State<UpdateItemScreen> {
  final int _storeId = 1;

  @override
  void initState() {
    super.initState();
    _loadStoreAndFetch();
  }

  Future<void> _loadStoreAndFetch() async {
    final itemsState = Provider.of<ItemsState>(context, listen: false);
    await itemsState.fetchItems(context, _storeId);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalization =
        Provider.of<LocalizationService>(context, listen: false);
    final r = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalization.getLocalizedString('updateItem')),
      ),
      body: Consumer<ItemsState>(
        builder: (context, itemsState, _) {
          if (itemsState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = itemsState.items;
          if (items.isEmpty) {
            return Center(
              child: Text(
                appLocalization.getLocalizedString('noDataAvailable'),
                style: TextStyle(fontSize: r.font(14)),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => itemsState.fetchItems(context, _storeId),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: r.scale(8)),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ItemCard(
                  item: item,
                  onEdit: () async {
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => EditItemDialog(item: item),
                    );
                  },
                  onDelete: () {
                    final screenContext = this.context;
                    CustomPopups.showCustomDialog(
                      context: screenContext,
                      icon: const Icon(Icons.delete,
                          color: AppColors.errorColor, size: 40),
                      title: appLocalization
                          .getLocalizedString('deleteConfirmationTitle'),
                      message: appLocalization
                          .getLocalizedString('deleteConfirmationBody'),
                      deleteButtonText:
                          appLocalization.getLocalizedString('delete'),
                      onPressButton: () async {
                        try {
                          debugPrint('Deleting item with id: ${item.itemId}');
                          final err = await itemsState.deleteItem(
                            screenContext,
                            item.itemId,
                          );
                          if (err == null) {
                            ScaffoldMessenger.of(screenContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                    appLocalization.getLocalizedString(
                                        'itemDeletedSuccessfully')),
                              ),
                            );
                            await itemsState.fetchItems(
                                screenContext, _storeId);
                          } else {
                            ScaffoldMessenger.of(screenContext).showSnackBar(
                              SnackBar(content: Text(err)),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(screenContext).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

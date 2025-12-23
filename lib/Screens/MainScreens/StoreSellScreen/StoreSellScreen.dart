import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Constants/app_color.dart';
import '../../../Models/ItemModel.dart';
import '../../../States/ItemsState.dart';
import '../../../services/LocalizationService.dart';
import 'widgets/SearchField.dart';
import 'widgets/bottom_sheet.dart';
import 'widgets/product_card.dart';

class StoreSellScreen extends StatefulWidget {
  @override
  _StoreSellScreenState createState() => _StoreSellScreenState();
}

class _StoreSellScreenState extends State<StoreSellScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ItemModel> filteredItems = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemState = Provider.of<ItemsState>(context, listen: false);
      itemState.items;

      itemState.addListener(() {
        if (mounted) {
          final newItems = itemState.items;
          setState(() {
            filteredItems = List.from(newItems);
            // Listen to changes only once, optionally (good for updates)
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterList(String query, List<ItemModel> originalList) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = List.from(originalList);
      } else {
        filteredItems = originalList
            .where((item) => item.itemName
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showBottomSheet(BuildContext context, ItemModel item) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      builder: (context) => BottomSheetWidget(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization =
        Provider.of<LocalizationService>(context, listen: false);
    double width = MediaQuery.of(context).size.width;
    int crossAxisCount = width < 600 ? 2 : 4;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Consumer<ItemsState>(
        builder: (context, itemState, _) {
          if (itemState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (itemState.errorMessage != null) {
            return Center(child: Text(itemState.errorMessage!));
          }

          final allItems = itemState.items;

          // Keep filtered list synced if it's empty
          if (filteredItems.isEmpty && _searchController.text.isEmpty) {
            filteredItems = List.from(allItems);
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SearchField(
                  controller: _searchController,
                  hintText: appLocalization.getLocalizedString('search'),
                  onChanged: (query) => _filterList(query, allItems),
                  onClear: () async {
                    setState(() {
                      _searchController.clear();
                      filteredItems = List.from(allItems);
                    });
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio:
                          1.5, // Adjust this value to make the cards taller or shorter
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return ProductCard(
                        item: item,
                        onTap: () => _showBottomSheet(context, item),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

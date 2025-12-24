import 'package:flutter/material.dart';
import '../Constants/app_color.dart';
import '../services/responsive.dart';
import '../Models/ItemModel.dart';
import 'LabeledValue.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    return Container(
      margin:
          EdgeInsets.symmetric(vertical: r.scale(6), horizontal: r.scale(8)),
      padding: EdgeInsets.all(r.scale(12)),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(r.scale(12)),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: r.scale(6),
            offset: Offset(0, r.scale(2)),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: r.font(16),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(height: r.scale(8)),
                Wrap(
                  spacing: r.scale(8),
                  runSpacing: r.scale(6),
                  children: [
                    LabeledValue(
                      label: 'Purchase',
                      value: item.purchasePrice.toStringAsFixed(2),
                      color: AppColors.secondaryColor,
                    ),
                    LabeledValue(
                      label: 'Selling',
                      value: item.sellingPrice.toStringAsFixed(2),
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: r.scale(4)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.edit,
                    color: AppColors.secondaryColor, size: r.scale(20)),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: r.scale(32),
                  minHeight: r.scale(32),
                ),
                visualDensity:
                    const VisualDensity(horizontal: -2, vertical: -2),
              ),
              SizedBox(width: r.scale(6)),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete,
                    color: AppColors.primaryColor, size: r.scale(20)),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: r.scale(32),
                  minHeight: r.scale(32),
                ),
                visualDensity:
                    const VisualDensity(horizontal: -2, vertical: -2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// LabeledValue moved to its own file for cleaner separation.

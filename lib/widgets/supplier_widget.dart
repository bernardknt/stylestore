import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class SupplierDropdownBottomSheet extends StatefulWidget {
  final List<String> supplierDisplayNames;
  final Function(String?) onSelected;

  const SupplierDropdownBottomSheet({
    Key? key,
    required this.supplierDisplayNames,
    required this.onSelected,
  }) : super(key: key);

  @override
  _SupplierDropdownBottomSheetState createState() =>
      _SupplierDropdownBottomSheetState();
}

class _SupplierDropdownBottomSheetState
    extends State<SupplierDropdownBottomSheet> {
  String? _selectedSupplier;
  String? _searchQuery;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important for BottomSheet
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Select Supplier", style: Theme.of(context).textTheme.headline6),
          SizedBox(height: 10),
          DropdownSearch<String>(

            items: widget.supplierDisplayNames,

            onChanged: (newValue) {
              setState(() {
                _selectedSupplier = newValue;
                widget.onSelected(newValue); // Notify parent
              });
              Navigator.pop(context); // Close the sheet
            },
            selectedItem: _selectedSupplier,
            filterFn: (item, query) =>
                item.toLowerCase().contains(query!.toLowerCase()),
          ),
        ],
      ),
    );
  }
}

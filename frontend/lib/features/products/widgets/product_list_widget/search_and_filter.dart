import 'package:flutter/material.dart';
import 'package:frontend/features/products/provider/product_provider.dart';
import 'package:provider/provider.dart';

class SearchAndFilter extends StatelessWidget {
  final TextEditingController searchController;
  final Function(ProductProvider) onFilterPressed;

  const SearchAndFilter({
    Key? key,
    required this.searchController,
    required this.onFilterPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            searchController.clear();
                            vm.onSearchChanged('');
                          },
                        )
                      : null,
                ),
                onChanged: vm.onSearchChanged,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: vm.sortOption.isNotEmpty
                  ? Theme.of(context).primaryColor
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: vm.sortOption.isNotEmpty
                    ? Theme.of(context).primaryColor
                    : Colors.grey[200]!,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.tune,
                color: vm.sortOption.isNotEmpty
                    ? Colors.white
                    : Colors.grey[600],
              ),
              onPressed: () => onFilterPressed(vm),
            ),
          ),
        ],
      ),
    );
  }
}

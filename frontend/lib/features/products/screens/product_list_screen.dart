import 'package:flutter/material.dart';
import 'package:frontend/features/products/provider/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/routes/router.dart';
import '../widgets/product_list_widget/search_and_filter.dart';
import '../widgets/product_list_widget/empty_state.dart';
import '../widgets/product_list_widget/error_state.dart';
import '../widgets/product_list_widget/product_card.dart';
import '../widgets/product_list_widget/sort_bottom_sheet.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortBottomSheet(ProductProvider vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SortBottomSheet(vm: vm),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          context.pushAddProduct();
          if (mounted) {
            context.read<ProductProvider>().refresh();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          SearchAndFilter(
            searchController: _searchController,
            onFilterPressed: (vm) => _showSortBottomSheet(vm),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (vm.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (vm.errorMessage != null) {
                  return ErrorState(vm: vm);
                } else if (vm.products.isEmpty) {
                  return const EmptyState();
                } else {
                  return RefreshIndicator(
                    onRefresh: vm.refresh,
                    color: Theme.of(context).primaryColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: vm.products.length,
                      itemBuilder: (context, index) {
                        final product = vm.products[index];
                        return ProductCard(
                          product: product,
                          onTap: () => context.goToProductDetails(product.id),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

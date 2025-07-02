import 'package:flutter/material.dart';
import 'package:frontend/features/products/widgets/product_details_widget/edit_product_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../model/product_model.dart';
import '../provider/product_details_provider.dart';
import '../widgets/product_details_widget/product_header.dart';
import '../widgets/product_details_widget/info_card.dart';
import '../widgets/product_details_widget/error_state.dart';
import '../widgets/product_details_widget/action_buttons.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProduct();
    });
  }

  Future<void> _loadProduct() async {
    try {
      await context.read<ProductDetailsProvider>().fetchProductDetails(
        widget.productId,
      );
      _animationController.forward();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Color _getStockColor(int stock) {
    if (stock > 20) return Colors.green;
    if (stock > 5) return Colors.orange;
    return Colors.red;
  }

  void _showEditBottomSheet(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProductBottomSheet(
        product: product,
        onSave: (updated) => _saveProduct(updated, original: product),
      ),
    );
  }

  Future<void> _saveProduct(
    Product updated, {
    required Product original,
  }) async {
    try {
      await context.read<ProductDetailsProvider>().updateProduct(updated);
      if (mounted) {
        Navigator.pop(context);
        _showSuccessSnackBar('Product updated successfully');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update product: $e');
    }
  }

  Future<void> _exportPdf() async {
    final provider = context.read<ProductDetailsProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer<ProductDetailsProvider>(
        builder: (_, p, __) {
          final progress = p.downloadProgress;
          final percent = (progress * 100).clamp(0, 100).toStringAsFixed(0);

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.file_download, color: Colors.orange),
                SizedBox(width: 8),
                Text('Downloading PDF'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: progress == 0 ? null : progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$percent%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      await provider.exportProductPdf(widget.productId);
      if (mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackBar('PDF downloaded successfully');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _showErrorSnackBar('Failed to download PDF: $e');
      }
    }
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Product'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this product? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await context.read<ProductDetailsProvider>().deleteProduct(
        widget.productId,
      );
      if (mounted) {
        Navigator.pop(context);
        _showSuccessSnackBar('Product deleted successfully');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to delete product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<ProductDetailsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.product == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return ProductDetailsErrorState(
              errorMessage: provider.error,
              onRetry: _loadProduct,
            );
          }

          final product = provider.product;
          if (product == null) {
            return const Center(
              child: Text('No product found', style: TextStyle(fontSize: 18)),
            );
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: Theme.of(context).primaryColor,
                  flexibleSpace: FlexibleSpaceBar(
                    background: ProductHeader(product: product),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        InfoCard(
                          icon: Icons.attach_money,
                          title: 'Price',
                          value: '\$${product.price.toStringAsFixed(2)}',
                          color: Colors.green,
                        ),
                        InfoCard(
                          icon: Icons.inventory,
                          title: 'Stock',
                          value: '${product.stock} units',
                          color: _getStockColor(product.stock),
                        ),
                        const SizedBox(height: 20),
                        ProductActionButtons(
                          onEdit: () => _showEditBottomSheet(product),
                          onPdf: _exportPdf,
                          onDelete: _confirmDelete,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

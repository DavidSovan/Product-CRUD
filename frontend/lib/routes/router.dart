import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/products/screens/product_list_screen.dart';
import '../features/products/screens/product_details_screen.dart';
import '../features/products/screens/add_product_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const ProductScreen(),
      routes: [
        GoRoute(
          path: 'product-details/:id',
          name: 'productDetails',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null) {
              return const ErrorScreen(message: 'Invalid product ID');
            }
            return ProductDetailsScreen(productId: id);
          },
        ),
        GoRoute(
          path: 'add-product',
          name: 'addProduct',
          builder: (context, state) => const AddProductScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) =>
      ErrorScreen(message: state.error?.toString() ?? 'Page not found'),
);

class ErrorScreen extends StatelessWidget {
  final String message;

  const ErrorScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension for easier navigation
extension GoRouterExtension on BuildContext {
  void goToProductDetails(int productId) {
    go('/product-details/$productId');
  }

  void pushProductDetails(int productId) {
    push('/product-details/$productId');
  }

  void goToAddProduct() {
    go('/add-product');
  }

  void pushAddProduct() {
    push('/add-product');
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../model/product_model.dart';
import '../service/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _search = '';
  String _sortOption = '';
  Timer? _debounce;
  bool _isDisposed = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get sortOption => _sortOption;

  @override
  void dispose() {
    _debounce?.cancel();
    _isDisposed = true;
    super.dispose();
  }

  // Safe notify listeners
  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // Search products
  void onSearchChanged(String query) {
    if (_search == query) return;
    _search = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchProducts();
    });
  }

  // Update sort option
  void updateSort(String sort) {
    if (_sortOption == sort) return;
    _sortOption = sort;
    fetchProducts();
  }

  // Fetch products
  Future<void> fetchProducts() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final products = await _service.fetchProducts(
        search: _search,
        sort: _sortOption,
      );

      if (!_isDisposed) {
        _products = products;
        if (_products.isEmpty) {
          _errorMessage = 'No products found';
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        _errorMessage = e.toString();
      }
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  // Retry fetching products
  Future<void> retry() async {
    fetchProducts();
  }

  // Refresh products
  Future<void> refresh() async {
    await fetchProducts();
  }

  // Create a new product
  Future<bool> createProduct({
    required String productName,
    required double price,
    required int stock,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      await _service.createProduct(
        productName: productName,
        price: price,
        stock: stock,
      );

      // Refresh the product list after successful creation
      await fetchProducts();
      return true;
    } catch (e) {
      if (!_isDisposed) {
        _errorMessage = e.toString();
        _safeNotifyListeners();
      }
      return false;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }
}

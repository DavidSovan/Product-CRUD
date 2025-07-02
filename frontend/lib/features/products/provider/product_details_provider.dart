import 'package:flutter/material.dart';
import '../model/product_model.dart';
import '../service/product_details_service.dart';

class ProductDetailsProvider with ChangeNotifier {
  final ProductDetailsService _productDetailsService = ProductDetailsService();

  Product? _product;
  bool _isLoading = false;
  String? _error;
  double _downloadProgress = 0.0;

  Product? get product => _product;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get downloadProgress => _downloadProgress;

  // Fetch product details
  Future<void> fetchProductDetails(int productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _product = await _productDetailsService.fetchProductDetails(productId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _product = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update product
  Future<void> updateProduct(Product updated) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _product = await _productDetailsService.updateProduct(updated);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Export product PDF
  Future<void> exportProductPdf(int id) async {
    _isLoading = true;
    _error = null;
    _downloadProgress = 0.0;
    notifyListeners();

    try {
      await _productDetailsService.exportProductPdf(
        id,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _downloadProgress = received / total;
            notifyListeners();
          }
        },
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      _downloadProgress = 0.0;
      notifyListeners();
    }
  }

  // Delete product
  Future<bool> deleteProduct(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _productDetailsService.deleteProduct(id);
      // Clear the locally cached product since it has been deleted.
      _product = null;
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear product
  void clearProduct() {
    _product = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}

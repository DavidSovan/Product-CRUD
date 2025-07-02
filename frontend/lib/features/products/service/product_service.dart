import 'package:dio/dio.dart';
import '../model/product_model.dart';
import '../../../core/network/dio_client.dart';

class ProductService {
  final Dio _dio = DioClient.client;

  // Fetches a list of products
  Future<List<Product>> fetchProducts({String? search, String? sort}) async {
    try {
      final response = await _dio.get(
        '/products',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (sort != null && sort.isNotEmpty) 'sort': sort,
        },
      );

      if (response.statusCode == 200 && response.data['success']) {
        final List products = response.data['data'];
        return products.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _dio.get(
        '/products',
        queryParameters: {'search': query},
      );

      if (response.statusCode == 200 && response.data['success']) {
        final List data = response.data['data'];
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Create a new product
  Future<Product> createProduct({
    required String productName,
    required double price,
    required int stock,
  }) async {
    try {
      final response = await _dio.post(
        '/products',
        data: {'product_name': productName, 'price': price, 'stock': stock},
      );

      if (response.statusCode == 201 && response.data['success']) {
        return Product.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create product');
      }
    } catch (e) {
      throw Exception('Error creating product: ${e.toString()}');
    }
  }

  // Delete a product
  Future<void> deleteProduct(int id) async {
    try {
      final response = await _dio.delete('/products/$id');

      if (!(response.statusCode == 200 && response.data['success'] == true)) {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      throw Exception('Error deleting product: ${e.toString()}');
    }
  }
}

import 'package:dio/dio.dart';
import '../model/product_model.dart';
import '../../../core/network/dio_client.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ProductDetailsService {
  final Dio _dio = DioClient.client;
  // Fetches a product by its ID and returns the [Product].
  Future<Product> fetchProductDetails(int productId) async {
    try {
      final response = await _dio.get(
        '/products/$productId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return Product.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load product details');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Failed to load product details: ${e.response?.statusCode}',
        );
      } else {
        throw Exception('Failed to connect to the server');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Updates an existing product and returns the updated [Product].
  Future<Product> updateProduct(Product product) async {
    try {
      final response = await _dio.put(
        '/products/${product.id}',
        data: product.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return Product.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update product');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to update product: ${e.response?.statusCode}');
      } else {
        throw Exception('Failed to connect to the server');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Deletes a product by its ID.
  Future<void> deleteProduct(int id) async {
    try {
      final response = await _dio.delete(
        '/products/$id',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (!(response.statusCode == 200 && response.data['success'] == true)) {
        throw Exception('Failed to delete product');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to delete product: ${e.response?.statusCode}');
      } else {
        throw Exception('Failed to connect to the server');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Export product as PDF and save to Downloads directory. Returns the saved [File].
  Future<File> exportProductPdf(
    int id, {
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Resolve the public downloads directory.
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        throw Exception('Unable to resolve the downloads directory');
      }
      final savePath = p.join(downloadsDir.path, 'product-$id.pdf');

      final response = await _dio.download(
        '/products/$id/pdf',
        savePath,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'application/pdf'},
        ),
        onReceiveProgress: onReceiveProgress,
      );

      if (response.statusCode == 200) {
        // Attempt to open the file so the user can view/share it.
        await OpenFile.open(savePath);
        return File(savePath);
      } else {
        throw Exception('Failed to download PDF');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to export PDF: ${e.response?.statusCode}');
      } else {
        throw Exception('Failed to connect to the server');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
}

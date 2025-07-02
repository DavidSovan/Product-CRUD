import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: '${dotenv.env['API_BASE_URL']}${dotenv.env['API_BASE_PATH']}',
      connectTimeout: Duration(
        milliseconds:
            int.tryParse(dotenv.env['API_TIMEOUT'] ?? '10000') ?? 10000,
      ),
      receiveTimeout: Duration(
        milliseconds:
            int.tryParse(dotenv.env['API_TIMEOUT'] ?? '10000') ?? 10000,
      ),
    ),
  );
  static Dio get client => _dio;
}

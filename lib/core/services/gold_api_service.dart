import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:aurum/core/constants/api_constants.dart';
import 'package:aurum/core/utils/app_logger.dart';
import 'package:aurum/data/models/gold_price_model.dart';

class GoldApiService {
  static final GoldApiService _instance = GoldApiService._internal();
  late final Dio _dio;

  factory GoldApiService() {
    return _instance;
  }

  GoldApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            AppLogger.d('REQUEST[${options.method}] => PATH: ${options.path}');
            return handler.next(options);
          },
          onResponse: (response, handler) {
            AppLogger.i('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
            return handler.next(response);
          },
          onError: (DioException e, handler) {
            AppLogger.e('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}', e);
            return handler.next(e);
          },
        ),
      );
    }
  }

  Future<GoldPriceModel> fetchLiveGoldPrice() async {
    try {
      final response = await _dio.get(ApiConstants.caratEndpoint, queryParameters: {
        'currency': 'INR',
      });

      if (response.statusCode == 200) {
        return GoldPriceModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load gold price. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection.');
      } else {
        throw Exception('An unexpected error occurred: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

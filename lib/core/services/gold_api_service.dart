import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:aurum/core/constants/api_constants.dart';
import 'package:aurum/core/utils/app_logger.dart';
import 'package:aurum/data/models/gold_price_model.dart';
import 'package:aurum/data/models/gold_bar_model.dart';
import 'package:aurum/data/models/indian_gold_rate_model.dart';

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
            AppLogger.d('DIAGNOSTIC REQUEST: ${options.method} ${options.baseUrl}${options.path}\nParams: ${options.queryParameters}');
            return handler.next(options);
          },
          onResponse: (response, handler) {
            return handler.next(response);
          },
          onError: (DioException e, handler) {
            return handler.next(e);
          },
        ),
      );
    }
  }

  Exception _handleDioException(DioException e) {
    AppLogger.e('DIAGNOSTIC ERROR TYPE: ${e.type}\nMESSAGE: ${e.message}');
    
    if (e.error is SocketException || e.message?.contains('Failed host lookup') == true) {
      AppLogger.e('DIAGNOSTIC CLASSIFICATION: NETWORK_UNAVAILABLE');
      return Exception('NETWORK_UNAVAILABLE');
    }

    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      AppLogger.e('DIAGNOSTIC CLASSIFICATION: API_ERROR\nSTATUS: $statusCode\nBODY: ${e.response!.data}');
      if ([401, 403, 404, 429, 500].contains(statusCode)) {
        return Exception('API_ERROR');
      }
    }

    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return Exception('NETWORK_UNAVAILABLE');
    }

    return Exception('UNKNOWN_API_ERROR: ${e.message}');
  }

  Future<IndianGoldRateModel> fetchIndianGoldRates() async {
    AppLogger.i('INDIAN GOLD API REQUEST');
    try {
      final response = await _dio.get('https://ibja-api.vercel.app/latest');

      if (response.statusCode == 200) {
        final model = IndianGoldRateModel.fromJson(response.data);
        
        // Validation - VERY IMPORTANT
        if (model.price24kPerGram <= 0 || model.price22kPerGram <= 0 || model.price18kPerGram <= 0) {
          AppLogger.e('INVALID GOLD PRICE RESPONSE: Prices must be > 0');
          throw Exception('INVALID_GOLD_PRICE');
        }
        if (model.price24kPerGram.isNaN || model.price22kPerGram.isNaN || model.price18kPerGram.isNaN) {
          AppLogger.e('INVALID GOLD PRICE RESPONSE: Prices must not be NaN');
          throw Exception('INVALID_GOLD_PRICE');
        }
        if (model.price24kPerGram.isInfinite || model.price22kPerGram.isInfinite || model.price18kPerGram.isInfinite) {
          AppLogger.e('INVALID GOLD PRICE RESPONSE: Prices must not be Infinity');
          throw Exception('INVALID_GOLD_PRICE');
        }
        if (model.price24kPerGram <= model.price22kPerGram) {
          AppLogger.e('INVALID GOLD PRICE RESPONSE: 24K must be > 22K');
          throw Exception('INVALID_GOLD_PRICE');
        }
        if (model.price22kPerGram <= model.price18kPerGram) {
          AppLogger.e('INVALID GOLD PRICE RESPONSE: 22K must be > 18K');
          throw Exception('INVALID_GOLD_PRICE');
        }

        AppLogger.i('INDIAN GOLD API SUCCESS\n24K: ₹${model.price24kPerGram}\n22K: ₹${model.price22kPerGram}\n18K: ₹${model.price18kPerGram}');
        return model;
      } else {
        AppLogger.e('INDIAN GOLD API FAILURE: Status Code: ${response.statusCode}');
        throw Exception('API_ERROR');
      }
    } on DioException catch (e) {
      AppLogger.e('INDIAN GOLD API FAILURE: ${e.message}');
      throw _handleDioException(e);
    } catch (e) {
      AppLogger.e('INDIAN GOLD API FAILURE: $e');
      throw Exception('An unexpected error occurred: $e');
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
        throw Exception('API_ERROR');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<GoldBarModel>> fetchHistoricalBars({required DateTime from, required DateTime to}) async {
    try {
      final response = await _dio.get('/bars', queryParameters: {
        'symbol': 'XAU-USD-SPOT',
        'interval': '1d',
        'from': from.toUtc().toIso8601String(),
        'to': to.toUtc().toIso8601String(),
        'limit': 100,
      });

      if (response.statusCode == 200) {
        final List<dynamic> barsJson = response.data['bars'] ?? [];
        AppLogger.i('BAR API SUCCESS: ${barsJson.length} bars');
        return barsJson.map((json) => GoldBarModel.fromJson(json)).toList();
      } else {
        AppLogger.e('BAR API FAILURE: Status Code: ${response.statusCode}');
        throw Exception('API_ERROR');
      }
    } on DioException catch (e) {
      AppLogger.e('BAR API FAILURE: ${e.message}');
      throw _handleDioException(e);
    } catch (e) {
      AppLogger.e('BAR API FAILURE: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

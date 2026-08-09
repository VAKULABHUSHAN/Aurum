import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.goldprice.dev/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        print('DIAGNOSTIC REQUEST: \${options.method} \${options.baseUrl}\${options.path}\\nParams: \${options.queryParameters}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('DIAGNOSTIC ERROR TYPE: \${e.type}\\nMESSAGE: \${e.message}');
        if (e.response != null) {
          print('DIAGNOSTIC CLASSIFICATION: API_ERROR\\nSTATUS: \${e.response!.statusCode}\\nBODY: \${e.response!.data}');
        }
        return handler.next(e);
      },
    ),
  );

  try {
    print('\\n--- Testing /carat ---');
    final res1 = await dio.get('/carat', queryParameters: {'currency': 'INR'});
    print('SUCCESS: \${res1.statusCode}');
  } catch (e) {
    print('FAILED: \$e');
  }

  try {
    print('\\n--- Testing /bars ---');
    final to = DateTime.now().toUtc();
    final from = to.subtract(const Duration(days: 30));
    final res2 = await dio.get('/bars', queryParameters: {
      'symbol': 'XAU-USD-SPOT',
      'interval': '1d',
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
      'limit': 100,
    });
    print('SUCCESS: \${res2.statusCode}');
  } catch (e) {
    print('FAILED: \$e');
  }
}


import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient()
      : dio = Dio(BaseOptions(
          baseUrl: "https://rickandmortyapi.com/api",
          connectTimeout: const Duration(seconds: 10),
        )) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print("Request: \${options.path}");
          return handler.next(options);
        },
        onError: (e, handler) {
          print("API Error: \${e.message}");
          return handler.next(e);
        },
      ),
    );
  }
}

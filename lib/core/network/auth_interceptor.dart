import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../storage/secure_storage_helper.dart';
import '../../../main.dart';
import '../../features/auth/presentation/pages/login_page.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorageHelper.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !(err.requestOptions.path.contains('/login'))) {
      await SecureStorageHelper.clearAll();

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
    super.onError(err, handler);
  }
}

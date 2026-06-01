import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_helper.dart';

enum AuthStateStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStateStatus status;
  final String? errorMessage;

  const AuthState({this.status = AuthStateStatus.initial, this.errorMessage});

  AuthState copyWith({AuthStateStatus? status, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final Dio _dio;

  @override
  AuthState build() {
    _dio = DioClient().dio;
    // We cannot await here since build is sync, but we can call an async function
    // and return the initial state. The UI will update when the state changes.
    // However, it's better to use Future.microtask or similar if it's async.
    Future.microtask(() => _checkInitialState());
    return const AuthState();
  }

  Future<void> _checkInitialState() async {
    final token = await SecureStorageHelper.getAccessToken();
    if (token != null) {
      state = state.copyWith(status: AuthStateStatus.authenticated);
    } else {
      state = state.copyWith(status: AuthStateStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStateStatus.loading, errorMessage: null);
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        await SecureStorageHelper.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        );
        state = state.copyWith(status: AuthStateStatus.authenticated);
        return true;
      } else {
        state = state.copyWith(
          status: AuthStateStatus.error,
          errorMessage: response.data['message'] ?? 'Login failed',
        );
        return false;
      }
    } on DioException catch (e) {
      log('DioException in login: $e');
      if (e.response != null) {
        log('Response data: ${e.response?.data}');
      }
      state = state.copyWith(
        status: AuthStateStatus.error,
        errorMessage: (e.response?.data is Map<String, dynamic>)
            ? e.response?.data['message'] ?? 'An error occurred during login'
            : 'An error occurred during login',
      );
      return false;
    } catch (e, stackTrace) {
      log('Unexpected error in login: $e\n$stackTrace');
      state = state.copyWith(
        status: AuthStateStatus.error,
        errorMessage: 'An unexpected error occurred',
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStateStatus.loading);
    try {
      // Best effort API call, ignore network failure
      await _dio.post('/logout');
    } catch (_) {
      // Ignore errors because we must force local cleanup anyway
    } finally {
      await SecureStorageHelper.clearAll();
      state = state.copyWith(status: AuthStateStatus.unauthenticated);
    }
  }

  void resetState() {
    state = state.copyWith(status: AuthStateStatus.initial, errorMessage: null);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

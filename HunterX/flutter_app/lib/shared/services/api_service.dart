import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  late Dio _dio;
  String _baseUrl = ApiConstants.defaultBaseUrl;

  ApiService() {
    _dio = _buildDio(_baseUrl);
    _loadSavedUrl();
  }

  Dio _buildDio(String baseUrl) => Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: ApiConstants.shortTimeout,
          receiveTimeout: ApiConstants.longTimeout,
          headers: {'Content-Type': 'application/json'},
        ),
      )..interceptors.add(LogInterceptor(responseBody: false));

  Future<void> _loadSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('server_url');
    if (saved != null && saved.isNotEmpty) {
      setBaseUrl(saved);
    }
  }

  void setBaseUrl(String url) {
    _baseUrl = url;
    _dio = _buildDio(url);
  }

  void setApiKey(String? key) {
    if (key != null && key.isNotEmpty) {
      _dio.options.headers['X-API-Key'] = key;
    } else {
      _dio.options.headers.remove('X-API-Key');
    }
  }

  String get baseUrl => _baseUrl;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? params, Duration? timeout}) async {
    return _dio.get<T>(
      path,
      queryParameters: params,
      options: timeout != null ? Options(receiveTimeout: timeout) : null,
    );
  }

  Future<Response<T>> post<T>(String path, {dynamic data, Duration? timeout}) async {
    return _dio.post<T>(
      path,
      data: data,
      options: timeout != null ? Options(receiveTimeout: timeout) : null,
    );
  }

  Future<bool> ping() async {
    try {
      final res = await _dio.get(ApiConstants.health);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

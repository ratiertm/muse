import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;
  
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
        receiveTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.keyAccessToken);
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized
          if (error.response?.statusCode == 401) {
            // Clear stored token
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove(AppConstants.keyAccessToken);
            await prefs.remove(AppConstants.keyUserId);
            await prefs.remove(AppConstants.keyUserName);
          }
          
          return handler.next(error);
        },
      ),
    );
    
    // Add error handler interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // Convert DioException to user-friendly Korean error
          final errorMessage = _getErrorMessage(error);
          print('API Error: $errorMessage');
          return handler.next(error);
        },
      ),
    );
  }
  
  Dio get dio => _dio;
  
  String get baseUrl => AppConstants.baseUrl;
  
  Future<String?> get token async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyAccessToken);
  }
  
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  /// Get user-friendly Korean error message from DioException
  String getErrorMessage(DioException error) {
    return _getErrorMessage(error);
  }
  
  String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '요청 시간이 초과되었습니다. 다시 시도해주세요.';
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return '잘못된 요청입니다. 입력 내용을 확인해주세요.';
          case 401:
            return '로그인이 만료되었습니다. 다시 로그인해주세요.';
          case 403:
            return '권한이 없습니다.';
          case 404:
            return '요청한 데이터를 찾을 수 없습니다.';
          case 429:
            return '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.';
          case 500:
          case 502:
          case 503:
            return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
          default:
            return '오류가 발생했습니다. (코드: $statusCode)';
        }
      
      case DioExceptionType.cancel:
        return '요청이 취소되었습니다.';
      
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
      default:
        if (error.message?.contains('SocketException') ?? false) {
          return '서버에 연결할 수 없습니다. 인터넷 연결을 확인해주세요.';
        }
        return '네트워크 오류가 발생했습니다. 연결 상태를 확인해주세요.';
    }
  }
}

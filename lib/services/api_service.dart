import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'https://ecommerce-backend-24ii.onrender.com/api/auth';
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> register(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '$baseUrl/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        },
      );
      if (response.data['token'] != null) {
        await _storage.write(key: 'jwt_token', value: response.data['token']);
      } else if (response.data['error'] != null) {
        throw Exception(response.data['error']);
      }
    } catch (e) {
      if (e is DioException && e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['error'] ?? 'Registration failed');
      }
      throw Exception(e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/login',
        data: {'email': email, 'password': password},
      );
      if (response.data['token'] != null) {
        await _storage.write(key: 'jwt_token', value: response.data['token']);
      } else if (response.data['error'] != null) {
        throw Exception(response.data['error']);
      }
    } catch (e) {
      if (e is DioException && e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['error'] ?? 'Login failed');
      }
      throw Exception(e.toString());
    }
  }

  Future<void> socialLogin(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('$baseUrl/social-login', data: data);
      if (response.data['token'] != null) {
        await _storage.write(key: 'jwt_token', value: response.data['token']);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post('$baseUrl/forgot-password', data: {'email': email});
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

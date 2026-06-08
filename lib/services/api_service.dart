import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../models/slideshow.dart';
import '../models/product_home.dart';

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

  Future<List<Slideshow>> getSlideshows() async {
    try {
      final response = await _dio.get('https://ecommerce-backend-24ii.onrender.com/api/slideshows');
      List data = response.data;
      return data.map((e) => Slideshow.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load slideshows: $e');
    }
  }

  Future<List<ProductHome>> getProductsByTag(String tagName) async {
    try {
      final response = await _dio.get('https://ecommerce-backend-24ii.onrender.com/api/products/home/tags/$tagName');
      List data = response.data;
      return data.map((e) => ProductHome.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load products for tag $tagName: $e');
    }
  }
}

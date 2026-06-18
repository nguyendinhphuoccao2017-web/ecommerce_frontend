import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../models/slideshow.dart';
import '../models/product_home.dart';
import '../models/category.dart';
import '../models/variant_option.dart';
import '../models/favorite_product.dart';
import '../models/product_detail.dart';
import '../models/cart_response.dart';
import '../models/customer_address.dart';

class ApiService {
  // Uncomment dòng dưới đây nếu muốn test backend trên máy local (dành cho iOS Simulator)
  // static const String apiBaseUrl = 'http://127.0.0.1:8080/api';
  // Uncomment dòng dưới đây nếu muốn test backend trên máy local (dành cho Android Emulator)
  // static const String apiBaseUrl = 'http://10.0.2.2:8080/api';
  
  static const String apiBaseUrl = 'https://ecommerce-backend-24ii.onrender.com/api';
  static const String baseUrl = '$apiBaseUrl/auth';
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
      String? token = await _storage.read(key: 'jwt_token');
      // Gửi kèm Token để truy cập API yêu cầu xác thực
      final response = await _dio.get(
        '$apiBaseUrl/slideshows/home',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      List data = response.data;
      return data.map((e) => Slideshow.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load slideshows: $e');
    }
  }

  Future<List<ProductHome>> getProductsByTag(String tagName) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      final response = await _dio.get(
        '$apiBaseUrl/products/home/tags/$tagName',
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      List data = response.data;
      return data.map((e) => ProductHome.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load products for tag $tagName: $e');
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('$apiBaseUrl/categories');
      List data = response.data;
      return data.map((e) => Category.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<List<ProductHome>> getProductsByCategory(String categoryId) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      final response = await _dio.get(
        '$apiBaseUrl/categories/$categoryId/products',
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      List data = response.data;
      return data.map((e) => ProductHome.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load products for category $categoryId: $e');
    }
  }

  Future<List<VariantOption>> getVariants(String productId) async {
    try {
      final response = await _dio.get('$apiBaseUrl/products/$productId/variants');
      List data = response.data;
      return data.map((e) => VariantOption.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load variants for product $productId: $e');
    }
  }

  Future<void> toggleFavorite(String productId, {String? variantOptionId}) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No token found');
      await _dio.post(
        '$apiBaseUrl/favorites/$productId/toggle',
        data: variantOptionId != null ? {'variantOptionId': variantOptionId} : null,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  Future<List<FavoriteProduct>> getFavoriteProducts() async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      if (token == null) return [];
      final response = await _dio.get(
        '$apiBaseUrl/favorites',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      List data = response.data;
      return data.map((e) => FavoriteProduct.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load favorite products: $e');
    }
  }

  Future<ProductDetail> getProductDetails(String productId) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      final response = await _dio.get(
        '$apiBaseUrl/products/$productId/details',
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      return ProductDetail.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load product details: $e');
    }
  }

  Future<List<ProductHome>> getRelatedProducts(String productId) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      final response = await _dio.get(
        '$apiBaseUrl/products/$productId/related',
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      List data = response.data;
      return data.map((e) => ProductHome.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load related products: $e');
    }
  }

  Future<Map<String, dynamic>> getReviews(String productId, int page, int size, bool withPhoto) async {
    try {
      final response = await _dio.get(
        '$apiBaseUrl/products/$productId/reviews',
        queryParameters: {
          'page': page,
          'size': size,
          'withPhoto': withPhoto,
        },
      );
      return response.data; // Expected format: {"content": [...], "totalPages": ...}
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  Future<Map<String, dynamic>> getReviewSummary(String productId) async {
    try {
      final response = await _dio.get('$apiBaseUrl/products/$productId/reviews/summary');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load review summary: $e');
    }
  }

  Future<void> postReview(String productId, int rating, String title, String comment, List<String> images) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No token found');
      await _dio.post(
        '$apiBaseUrl/products/$productId/reviews',
        data: {
          'rating': rating,
          'title': title,
          'comment': comment,
          'images': images,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      throw Exception('Failed to post review: $e');
    }
  }

  Future<void> incrementHelpfulCount(String reviewId) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      await _dio.post(
        '$apiBaseUrl/product-reviews/$reviewId/helpful',
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
    } catch (e) {
      throw Exception('Failed to increment helpful count: $e');
    }
  }

  Future<List<dynamic>> getCoupons() async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      final response = await _dio.get(
        '$apiBaseUrl/coupons',
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load coupons: $e');
    }
  }

  Future<CartResponse> getCart() async {
    // We will parse it to Dart model CartResponse
    try {
      String? token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No token found');
      final response = await _dio.get(
        '$apiBaseUrl/cards/my-cart',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return CartResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get cart: $e');
    }
  }

  Future<void> addToCart(String productId, String? variantOptionId, int quantity) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No token found');
      await _dio.post(
        '$apiBaseUrl/cards/add',
        data: {
          'productId': productId,
          'variantOptionId': variantOptionId,
          'quantity': quantity,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  Future<List<CustomerAddress>> getShippingAddresses() async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No token found');
      final response = await _dio.get(
        '$apiBaseUrl/customer-addresses/my-addresses',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      List data = response.data;
      return data.map((e) => CustomerAddress.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load shipping addresses: $e');
    }
  }

  Future<void> addShippingAddress(Map<String, dynamic> data) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No token found');
      await _dio.post(
        '$apiBaseUrl/customer-addresses/add',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      throw Exception('Failed to add shipping address: $e');
    }
  }

  Future<void> updateShippingAddress(String id, Map<String, dynamic> data) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No token found');
      await _dio.put(
        '$apiBaseUrl/customer-addresses/$id',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      throw Exception('Failed to update shipping address: $e');
    }
  }

  Future<void> submitCheckout(Map<String, dynamic> data) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No token found');
      await _dio.post(
        '$apiBaseUrl/checkout/submit',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      throw Exception('Failed to submit checkout: $e');
    }
  }
}

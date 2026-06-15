import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final reviewSummaryProvider = FutureProvider.family<ReviewSummary, String>((ref, productId) async {
  final apiService = ref.read(apiServiceProvider);
  final data = await apiService.getReviewSummary(productId);
  return ReviewSummary.fromJson(data);
});

class ReviewState {
  final List<Review> reviews;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final bool withPhoto;

  ReviewState({
    required this.reviews,
    required this.isLoading,
    required this.hasMore,
    required this.page,
    required this.withPhoto,
  });

  ReviewState copyWith({
    List<Review>? reviews,
    bool? isLoading,
    bool? hasMore,
    int? page,
    bool? withPhoto,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      withPhoto: withPhoto ?? this.withPhoto,
    );
  }
}

class ReviewNotifier extends StateNotifier<ReviewState> {
  final ApiService apiService;
  final String productId;

  ReviewNotifier(this.apiService, this.productId)
      : super(ReviewState(
          reviews: [],
          isLoading: false,
          hasMore: true,
          page: 0,
          withPhoto: false,
        )) {
    loadMoreReviews();
  }

  void setWithPhoto(bool value) {
    if (state.withPhoto == value) return;
    state = state.copyWith(
      reviews: [],
      hasMore: true,
      page: 0,
      withPhoto: value,
    );
    loadMoreReviews();
  }

  Future<void> loadMoreReviews() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final response = await apiService.getReviews(
        productId,
        state.page,
        5,
        state.withPhoto,
      );

      final List<dynamic> content = response['content'] ?? [];
      final int totalPages = response['totalPages'] ?? 1;

      final newReviews = content.map((e) => Review.fromJson(e)).toList();

      state = state.copyWith(
        reviews: [...state.reviews, ...newReviews],
        page: state.page + 1,
        hasMore: state.page + 1 < totalPages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void refresh() {
    state = state.copyWith(
      reviews: [],
      hasMore: true,
      page: 0,
    );
    loadMoreReviews();
  }

  Future<void> incrementHelpfulCount(String reviewId) async {
    try {
      // Optimistic UI update
      final updatedReviews = state.reviews.map((review) {
        if (review.id == reviewId) {
          return Review(
            id: review.id,
            rating: review.rating,
            title: review.title,
            comment: review.comment,
            images: review.images,
            helpfulCount: review.helpfulCount + 1,
            createdAt: review.createdAt,
            firstName: review.firstName,
            lastName: review.lastName,
            avatar: review.avatar,
          );
        }
        return review;
      }).toList();

      state = state.copyWith(reviews: updatedReviews);

      // Async background call
      await apiService.incrementHelpfulCount(reviewId);
    } catch (e) {
      // If error, rollback or ignore (usually ignore in optimistic updates unless critical)
    }
  }
}

final reviewNotifierProvider = StateNotifierProvider.family<ReviewNotifier, ReviewState, String>((ref, productId) {
  final apiService = ref.read(apiServiceProvider);
  return ReviewNotifier(apiService, productId);
});

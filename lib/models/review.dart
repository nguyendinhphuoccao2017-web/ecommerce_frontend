class Review {
  final String id;
  final int rating;
  final String title;
  final String comment;
  final List<String> images;
  final int helpfulCount;
  final DateTime createdAt;
  final String firstName;
  final String lastName;
  final String? avatar;

  Review({
    required this.id,
    required this.rating,
    required this.title,
    required this.comment,
    required this.images,
    required this.helpfulCount,
    required this.createdAt,
    required this.firstName,
    required this.lastName,
    this.avatar,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      rating: json['rating'] ?? 0,
      title: json['title'] ?? '',
      comment: json['comment'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      helpfulCount: json['helpfulCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      firstName: json['firstName'] ?? 'Anonymous',
      lastName: json['lastName'] ?? 'User',
      avatar: json['avatar'],
    );
  }
}

class ReviewSummary {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  ReviewSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> rawDistribution = json['ratingDistribution'] ?? {};
    Map<int, int> parsedDistribution = {};
    rawDistribution.forEach((key, value) {
      parsedDistribution[int.parse(key)] = value is int ? value : (value as num).toInt();
    });

    return ReviewSummary(
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      ratingDistribution: parsedDistribution,
    );
  }
}

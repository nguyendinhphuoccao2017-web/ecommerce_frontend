import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/review_provider.dart';
import '../widgets/review_card.dart';
import '../widgets/write_review_bottom_sheet.dart';
import '../models/review.dart';

class ReviewsScreen extends ConsumerWidget {
  final String productId;

  const ReviewsScreen({Key? key, required this.productId}) : super(key: key);

  void _showWriteReviewBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return WriteReviewBottomSheet(productId: productId);
      },
    ).then((submitted) {
      if (submitted == true) {
        // Option to refresh if we wanted to
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(reviewSummaryProvider(productId));
    final reviewState = ref.watch(reviewNotifierProvider(productId));
    final reviewNotifier = ref.read(reviewNotifierProvider(productId).notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rating&Reviews',
          style: TextStyle(
            color: Color(0xFF222222),
            fontFamily: 'Metropolis',
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: summaryAsync.when(
                data: (summary) {
                  return _buildSummarySection(summary);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  summaryAsync.maybeWhen(
                    data: (summary) => Text(
                      '${summary.totalReviews} reviews',
                      style: const TextStyle(
                        fontFamily: 'Metropolis',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Color(0xFF222222),
                      ),
                    ),
                    orElse: () => const Text('Reviews', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: reviewState.withPhoto,
                        activeColor: const Color(0xFFDB3022),
                        onChanged: (value) {
                          if (value != null) {
                            reviewNotifier.setWithPhoto(value);
                          }
                        },
                      ),
                      const Text(
                        'With photo',
                        style: TextStyle(
                          fontFamily: 'Metropolis',
                          fontSize: 14,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < reviewState.reviews.length) {
                  return ReviewCard(
                    review: reviewState.reviews[index],
                    productId: productId,
                  );
                } else if (reviewState.hasMore) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    reviewNotifier.loadMoreReviews();
                  });
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return const SizedBox(height: 100);
              },
              childCount: reviewState.reviews.length + (reviewState.hasMore ? 1 : 0),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showWriteReviewBottomSheet(context),
        backgroundColor: const Color(0xFFDB3022),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          'Write a review',
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Widget _buildSummarySection(ReviewSummary summary) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.averageRating.toStringAsFixed(1),
              style: const TextStyle(
                fontFamily: 'Metropolis',
                fontWeight: FontWeight.bold,
                fontSize: 44,
                color: Color(0xFF222222),
              ),
            ),
            Text(
              '${summary.totalReviews} ratings',
              style: const TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 14,
                color: Color(0xFF9B9B9B),
              ),
            ),
          ],
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: List.generate(5, (index) {
              final starCount = 5 - index;
              final count = summary.ratingDistribution[starCount] ?? 0;
              final ratio = summary.totalReviews > 0 ? count / summary.totalReviews : 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < starCount ? Icons.star : Icons.star_border,
                          size: 14,
                          color: starIndex < starCount ? const Color(0xFFFFBA49) : Colors.transparent,
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio,
                          backgroundColor: const Color(0xFFF9F9F9),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFDB3022)),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 24,
                      child: Text(
                        '$count',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFamily: 'Metropolis',
                          fontSize: 14,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

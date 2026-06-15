import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/review_provider.dart';
import '../widgets/review_card.dart';
import '../widgets/write_review_bottom_sheet.dart';
import '../models/review.dart';

class ReviewsScreen extends ConsumerStatefulWidget {
  final String productId;

  const ReviewsScreen({Key? key, required this.productId}) : super(key: key);

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  bool _isRefreshing = false;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 120 && !_showTitle) {
        setState(() => _showTitle = true);
      } else if (_scrollController.offset <= 120 && _showTitle) {
        setState(() => _showTitle = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showWriteReviewBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return WriteReviewBottomSheet(productId: widget.productId);
      },
    ).then((submitted) {
      if (submitted == true) {
        setState(() {
          _isRefreshing = true;
        });
        ref.invalidate(reviewSummaryProvider(widget.productId));
        ref.read(reviewNotifierProvider(widget.productId).notifier).refresh();
        
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _isRefreshing = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(reviewSummaryProvider(widget.productId));
    final reviewState = ref.watch(reviewNotifierProvider(widget.productId));
    final reviewNotifier = ref.read(reviewNotifierProvider(widget.productId).notifier);

    return Stack(
      children: [
        Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: AnimatedOpacity(
          opacity: _showTitle ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: const Text(
            'Rating and reviews',
            style: TextStyle(
              color: Color(0xFF222222),
              fontFamily: 'Metropolis',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
              child: Text(
                'Rating&Reviews',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
                  color: Color(0xFF222222),
                ),
              ),
            ),
          ),
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
                        activeColor: const Color(0xFF222222),
                        checkColor: const Color(0xFFFFFFFF),
                        side: const BorderSide(color: Color(0xFF222222), width: 1.5),
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
                    productId: widget.productId,
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
    ),
        if (_isRefreshing)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFDB3022)),
              ),
            ),
          ),
      ],
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
                    SizedBox(
                      width: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: List.generate(starCount, (starIndex) {
                          return const Icon(
                            Icons.star,
                            size: 14,
                            color: Color(0xFFFFBA49),
                          );
                        }),
                      ),
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

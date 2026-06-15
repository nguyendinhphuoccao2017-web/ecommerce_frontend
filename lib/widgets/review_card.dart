import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review.dart';
import '../providers/review_provider.dart';
import 'dynamic_initials_avatar.dart';

class ReviewCard extends ConsumerStatefulWidget {
  final Review review;
  final String productId;

  const ReviewCard({
    Key? key,
    required this.review,
    required this.productId,
  }) : super(key: key);

  @override
  ConsumerState<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends ConsumerState<ReviewCard> {
  bool isHelpfulPressed = false;

  void _onHelpfulTapped() {
    if (isHelpfulPressed) return;

    setState(() {
      isHelpfulPressed = true;
    });

    ref.read(reviewNotifierProvider(widget.productId).notifier).incrementHelpfulCount(widget.review.id);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // White Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 16, left: 16),
            padding: const EdgeInsets.only(
              top: 24.0,
              left: 24.0,
              right: 16.0,
              bottom: 16.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.review.firstName} ${widget.review.lastName}',
                  style: const TextStyle(
                    fontFamily: 'Metropolis',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < widget.review.rating ? Icons.star : Icons.star_border,
                          color: index < widget.review.rating ? const Color(0xFFFFBA49) : Colors.grey,
                          size: 14,
                        );
                      }),
                    ),
                    Text(
                      _formatDate(widget.review.createdAt),
                      style: const TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 11,
                        color: Color(0xFF9B9B9B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.review.comment,
                  style: const TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF222222),
                  ),
                ),
                if (widget.review.images.isNotEmpty && ref.watch(reviewNotifierProvider(widget.productId)).withPhoto) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 104,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.review.images.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: Image.network(
                            widget.review.images[index],
                            width: 104,
                            height: 104,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _onHelpfulTapped,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Helpful',
                          style: TextStyle(
                            fontFamily: 'Metropolis',
                            fontSize: 11,
                            color: isHelpfulPressed ? const Color(0xFFDB3022) : const Color(0xFF9B9B9B),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.thumb_up,
                          size: 14,
                          color: isHelpfulPressed ? const Color(0xFFDB3022) : const Color(0xFF9B9B9B),
                        ),
                        if (widget.review.helpfulCount > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${widget.review.helpfulCount})',
                            style: const TextStyle(
                              fontFamily: 'Metropolis',
                              fontSize: 11,
                              color: Color(0xFF9B9B9B),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Avatar
          Positioned(
            top: 0,
            left: 0,
            child: DynamicInitialsAvatar(
              firstName: widget.review.firstName,
              lastName: widget.review.lastName,
              avatarUrl: widget.review.avatar,
              radius: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

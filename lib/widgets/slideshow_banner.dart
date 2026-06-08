import 'package:flutter/material.dart';
import '../models/slideshow.dart';

class SlideshowBanner extends StatelessWidget {
  final Slideshow slideshow;
  final VoidCallback? onCheckPressed;

  const SlideshowBanner({super.key, required this.slideshow, this.onCheckPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(slideshow.image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              slideshow.title ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                fontFamily: 'Metropolis',
                height: 1.0,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onCheckPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDB3022),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text(
                'Check',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

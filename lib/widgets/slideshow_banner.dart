import 'package:flutter/material.dart';
import '../models/slideshow.dart';

class SlideshowBanner extends StatelessWidget {
  final Slideshow slideshow;
  final VoidCallback? onCheckPressed;

  const SlideshowBanner({super.key, required this.slideshow, this.onCheckPressed});

  @override
  Widget build(BuildContext context) {
    final bool isFirstBanner = slideshow.displayOrder == 1;

    return Container(
      height: 500,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(slideshow.image),
          fit: BoxFit.cover,
        ),
      ),
      child: isFirstBanner
          ? Container(
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
              padding: const EdgeInsets.only(left: 16.0, bottom: 24.0, right: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slideshow.title?.replaceAll(' ', '\n') ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Metropolis',
                      height: 1.0,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: onCheckPressed,
                    child: Container(
                      width: 160,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDB3022),
                        borderRadius: BorderRadius.circular(24),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/button/check_button.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Check',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

import 'package:flutter/material.dart';

class PaymentCardWidget extends StatelessWidget {
  final bool isBlackCard;
  final String cardNumber;
  final String cardHolderName;
  final String expiryDate;
  final bool isVisa;

  const PaymentCardWidget({
    super.key,
    required this.isBlackCard,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    required this.isVisa,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 216,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isBlackCard ? const Color(0xFF222222) : const Color(0xFF9B9B9B),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: CardBackgroundPainter(isBlackCard: isBlackCard),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: isVisa ? _buildVisaLayout() : _buildMastercardLayout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMastercardLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Left Chip
        Container(
          width: 32,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFFFCC66),
            borderRadius: BorderRadius.circular(4),
          ),
          child: CustomPaint(painter: ChipPainter()),
        ),
        const Spacer(),
        // Card Number
        Text(
          cardNumber,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            letterSpacing: -0.41,
            fontFamily: 'Metropolis',
            height: 22 / 24,
          ),
        ),
        const SizedBox(height: 32),
        // Bottom row: Holder Name, Expiry, Logo
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Card Holder Name',
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cardHolderName,
                  style: const TextStyle(
                    fontFamily: 'Metropolis',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Expiry Date',
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expiryDate,
                  style: const TextStyle(
                    fontFamily: 'Metropolis',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            _buildMastercardLogo(),
          ],
        ),
      ],
    );
  }

  Widget _buildVisaLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Right Visa Logo
        Align(
          alignment: Alignment.topRight,
          child: Image.network(
            'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/payment/Visa%20Logo.png',
            height: 20,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Text(
              'VISA',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic),
            ),
          ),
        ),
        const Spacer(),
        // Card Number
        Text(
          cardNumber,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            letterSpacing: -0.41,
            fontFamily: 'Metropolis',
            height: 22 / 24,
          ),
        ),
        const SizedBox(height: 16),
        // Chip below number row
        Container(
          width: 32,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFFFCC66),
            borderRadius: BorderRadius.circular(4),
          ),
          child: CustomPaint(painter: ChipPainter()),
        ),
        const SizedBox(height: 12),
        // Bottom row: Holder Name, Expiry
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Card Holder Name',
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cardHolderName,
                  style: const TextStyle(
                    fontFamily: 'Metropolis',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Expiry Date',
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expiryDate,
                  style: const TextStyle(
                    fontFamily: 'Metropolis',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMastercardLogo() {
    return Image.network(
      'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/payment/mastercard.png',
      width: 40,
      height: 24,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => SizedBox(
        width: 40,
        height: 24,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: const Color(0xFFEB001B).withOpacity(0.9), shape: BoxShape.circle),
              ),
            ),
            Positioned(
              right: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: const Color(0xFFF79E1B).withOpacity(0.9), shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardBackgroundPainter extends CustomPainter {
  final bool isBlackCard;

  CardBackgroundPainter({required this.isBlackCard});

  @override
  void paint(Canvas canvas, Size size) {
    if (isBlackCard) {
      final paintCircle = Paint()
        ..color = Colors.white.withOpacity(0.03)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width * 1.1, size.height * 0.1), size.height * 0.7, paintCircle);

      final paintWave = Paint()
        ..color = Colors.white.withOpacity(0.04)
        ..style = PaintingStyle.fill;
      final path = Path();
      path.moveTo(0, size.height * 0.65);
      path.quadraticBezierTo(size.width * 0.2, size.height * 0.5, size.width * 0.45, size.height * 0.65);
      path.quadraticBezierTo(size.width * 0.7, size.height * 0.8, size.width, size.height * 0.45);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      canvas.drawPath(path, paintWave);
    } else {
      final paintWave = Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.fill;
      final path = Path();
      path.moveTo(0, size.height * 0.8);
      path.quadraticBezierTo(size.width * 0.25, size.height * 0.4, size.width * 0.55, size.height * 0.6);
      path.quadraticBezierTo(size.width * 0.8, size.height * 0.75, size.width, size.height * 0.45);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      canvas.drawPath(path, paintWave);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width * 0.3, size.height * 0.3), paint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width * 0.3, size.height * 0.7), paint);
    
    canvas.drawLine(Offset(size.width * 0.7, size.height * 0.3), Offset(size.width, size.height * 0.3), paint);
    canvas.drawLine(Offset(size.width * 0.7, size.height * 0.7), Offset(size.width, size.height * 0.7), paint);

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.3, size.height * 0.15, size.width * 0.4, size.height * 0.7), const Radius.circular(2)), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

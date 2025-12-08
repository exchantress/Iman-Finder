import 'dart:math';
import 'package:flutter/material.dart';

class CompassDisplay extends StatelessWidget {
  final double heading; // heading perangkat (deg)
  final double qiblaDirection; // arah kiblat (deg)
  final bool isFacing; // apakah menghadap kiblat (tolerance)

  const CompassDisplay({
    super.key,
    required this.heading,
    required this.qiblaDirection,
    required this.isFacing,
  });

  @override
  Widget build(BuildContext context) {
    // rotasi background kompas: kita putar background supaya menunjukkan arah utara relatif ke device
    final double compassRotation = -heading * pi / 180;

    // rotasi panah qibla relatif terhadap layar:
    // ketika heading == qiblaDirection -> arrow harus tegak (0 rad)
    final double qiblaRotation = 0; //(qiblaDirection - heading) * pi / 180;

    return SizedBox(
      width: 320,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // background kompas (gambar jika disediakan, fallback custom paint)
          Transform.rotate(
            angle: compassRotation,
            child: SizedBox(
              width: 300,
              height: 300,
              child: _CompassBackground(),
            ),
          ),
          Positioned(
            left: 160 + (120 * sin((qiblaDirection - heading) * pi / 180)) - 20,
            top: 160 - (120 * cos((qiblaDirection - heading) * pi / 180)) - 20,
            child: Image.asset('assets/kabah.png', width: 40, height: 40),
          ),
          // panah kiblat (diputar sesuai qiblaRotation)
          Transform.rotate(
            angle: qiblaRotation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.navigation,
                  size: 64,
                  color: isFacing ? Colors.green : Colors.redAccent,
                ),
                const SizedBox(height: 6),
                Text(
                  'Qibla',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isFacing ? Colors.green : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),

          // titik pusat
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassBackground extends StatelessWidget {
  const _CompassBackground({super.key});

  @override
  Widget build(BuildContext context) {
    // Jika Anda memiliki asset compass image, pakai Image.asset('assets/compass.png')
    // Untuk sekarang gunakan CustomPaint fallback.
    return CustomPaint(painter: _CompassPainter());
  }
}

class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.45;

    final fill = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fill);

    final border = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, border);

    final textPainter = (String text, Offset pos) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    };

    textPainter('N', center + Offset(0, -radius + 14));
    textPainter('E', center + Offset(radius - 12, 0));
    textPainter('S', center + Offset(0, radius - 14));
    textPainter('W', center + Offset(-radius + 12, 0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

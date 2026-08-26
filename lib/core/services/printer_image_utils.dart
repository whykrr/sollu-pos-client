import 'dart:typed_data';
import 'package:image/image.dart' as img;

img.Image? processReceiptLogo(Map<String, dynamic> args) {
  final bytes = args['bytes'] as Uint8List;
  final paperWidthDots =
      (args['paperWidthDots'] as int?) ?? (args['width'] as int? ?? 384);
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;

  // 1. Flatten transparent alpha channel over solid white (#FFFFFF)
  final flattened =
      img.Image(width: decoded.width, height: decoded.height, numChannels: 3);
  for (var y = 0; y < decoded.height; y++) {
    for (var x = 0; x < decoded.width; x++) {
      final p = decoded.getPixel(x, y);
      final a = p.a / 255.0;
      if (a < 1.0) {
        final r = ((p.r * a) + (255 * (1 - a))).round().clamp(0, 255);
        final g = ((p.g * a) + (255 * (1 - a))).round().clamp(0, 255);
        final b = ((p.b * a) + (255 * (1 - a))).round().clamp(0, 255);
        flattened.setPixelRgb(x, y, r, g, b);
      } else {
        flattened.setPixelRgb(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt());
      }
    }
  }

  // 2. Scale logo width to ~66% of paper width (e.g. 256px for 58mm / 384px for 80mm)
  final targetLogoWidth = (paperWidthDots * 0.66).round();
  var resizedLogo = img.copyResize(flattened, width: targetLogoWidth);

  // 3. Cap max height to 220px for proportional logo display
  const int maxHeight = 220;
  if (resizedLogo.height > maxHeight) {
    resizedLogo = img.copyResize(resizedLogo, height: maxHeight);
  }

  // 4. Create FULL PAPER WIDTH white canvas (e.g., 384px for 58mm, 576px for 80mm)
  final canvas = img.Image(
      width: paperWidthDots, height: resizedLogo.height, numChannels: 3);
  for (var y = 0; y < canvas.height; y++) {
    for (var x = 0; x < canvas.width; x++) {
      canvas.setPixelRgb(x, y, 255, 255, 255);
    }
  }

  // 5. Draw logo in the center of the white canvas
  final dstX = ((paperWidthDots - resizedLogo.width) / 2).round();
  img.compositeImage(canvas, resizedLogo, dstX: dstX, dstY: 0);

  // 6. Convert full canvas to grayscale for clean thermal dithering
  return img.grayscale(canvas);
}

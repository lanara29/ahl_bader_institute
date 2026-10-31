import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final file = File('assets/images/logo.png');
  final bytes = await file.readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final image = frame.image;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = 1024.0;
  
  // White background
  final bgPaint = Paint()..color = Colors.white;
  canvas.drawRect(Rect.fromLTWH(0, 0, size, size), bgPaint);

  // Draw logo scaled down with padding (68% size, centered)
  final scale = 0.68;
  final targetW = size * scale;
  final targetH = size * scale;
  final left = (size - targetW) / 2;
  final top = (size - targetH) / 2;

  final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
  final dst = Rect.fromLTWH(left, top, targetW, targetH);
  canvas.drawImageRect(image, src, dst, Paint()..filterQuality = FilterQuality.high);

  final picture = recorder.endRecording();
  final outImage = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await outImage.toByteData(format: ui.ImageByteFormat.png);
  
  final outFile = File('assets/images/app_icon.png');
  await outFile.writeAsBytes(byteData!.buffer.asUint8List());
  print('SUCCESS: Created assets/images/app_icon.png with padding');
  exit(0);
}

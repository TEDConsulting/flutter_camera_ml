import 'package:flutter/material.dart';

class RectanglePainter extends CustomPainter {
  Offset start;
  final Offset end;
  final String text;

  RectanglePainter({
    this.start,
    this.end,
    this.text,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromPoints(start, end),
      Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    TextSpan textSpan = TextSpan(
      style: TextStyle(
        color: Colors.green,
        fontSize: 12.0,
        fontWeight: FontWeight.bold,
      ),
      text: text,
    );

    //Draw text
    TextPainter tp = TextPainter(
      text: textSpan,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(start.dx, end.dy));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

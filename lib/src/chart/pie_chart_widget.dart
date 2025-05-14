import 'dart:math';

import 'package:flutter/material.dart';

class PieChartWidget extends CustomPainter {
  PieChartWidget({required this.categories, required this.width});

  final List<Category> categories;
  final double width;
  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);

    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width / 2;

    double total = 0;
    for (var element in categories) {
      total += element.amount;
    }

    double startRadian = -pi / 2;

    for (var index = 0; index < categories.length; index++) {
      final currentCategory = categories.elementAt(index);
      final sweepRadian = currentCategory.amount / total * 2 * pi;
      paint.color = kNeumorphicColors.elementAt(index % categories.length);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startRadian,
        sweepRadian,
        false,
        paint,
      );
      startRadian += sweepRadian;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class Category {
  Category(this.name, {required this.amount});

  final String name;
  final double amount;
}

final kCategories = [
  Category('한국문학', amount: 500.00),
  Category('서양철학', amount: 150.00),
  Category('영미문학', amount: 90.00),
  Category('강연집 / 수필집', amount: 90.00),
  Category('심리학', amount: 40.00),
  Category('기타', amount: 20.00),
];

final kNeumorphicColors = [
  const Color.fromRGBO(82, 98, 255, 1),
  const Color.fromRGBO(46, 198, 255, 1),
  const Color.fromRGBO(123, 201, 82, 1),
  const Color.fromRGBO(255, 171, 67, 1),
  const Color.fromRGBO(252, 91, 57, 1),
  const Color.fromRGBO(139, 135, 130, 1),
];
import 'package:flutter/material.dart';

class CalendarDot extends StatelessWidget {
  final Color color;

  const CalendarDot(this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

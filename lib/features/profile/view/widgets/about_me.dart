import 'package:flutter/material.dart';

class AboutMe extends StatelessWidget {
  final String title;
  final String content;
  final Color accentColor;

  const AboutMe({
    super.key,
    required this.title,
    required this.content,
    this.accentColor = const Color(0xFF00C853),
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
  });

  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              title,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          content,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

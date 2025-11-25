import 'package:flutter/material.dart';

class AboutMe extends StatelessWidget {
  final String title;
  final String content;
  final Color accentColor;

  const AboutMe({
    Key? key,
    required this.title,
    required this.content,
    this.accentColor = const Color.fromARGB(255, 215, 76, 30), // bright green
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // dark card color
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              child: Row(
                children: [
                  // Left column: title + text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row with small green vertical line
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // vertical accent bar
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
                        // Body text
                        Text(
                          content,
                          style: TextStyle(
                            color: Colors.grey[300],
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

            // Thin green top border (rounded)
           
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// A single badge chip: colored shield icon + label inside a rounded box
class BadgeChip extends StatelessWidget {
  final String label;
  final Color chipColor; // color used for the small shield
  final double height;

  const BadgeChip({
    Key? key,
    required this.label,
    required this.chipColor,
    this.height = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderColor = chipColor.withOpacity(0.25);
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        // color: Colors.black.withOpacity(0.25), // slightly translucent inside
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.25),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // small shield circle that represents the badge icon
          Container(
            width: 26,
            // height: 26,
            decoration: BoxDecoration(
              color: chipColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  // color: chipColor.withOpacity(0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              // you can replace this with Image.asset(...) if you have shield images
              child: Icon(Icons.shield, size: 14, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFECECEC),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// The full badges section: top green strip, title with left accent bar and a wrap of badges
class BadgesSection extends StatelessWidget {
  final String title;
  final List<BadgeChip> badges;
  final Color accentColor;

  /// imagePath param is provided if you want to show an icon from local asset (not required)
  final String? imagePath;

  const BadgesSection({
    Key? key,
    required this.title,
    required this.badges,
    this.accentColor = const Color(0xFF1ED760),
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // Title row
                Row(
                  children: [
                    // vertical accent bar
                    Container(
                      width: 4,
                      height: 22,
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Badges wrap
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      alignment: WrapAlignment.start,
                      runSpacing: 6,
                      spacing: 0,
                      children: badges,
                    );
                  },
                ),
              ],
            ),

            // Thin green top border (rounded like the screenshot)
          ],
        ),
      ),
    );
  }
}

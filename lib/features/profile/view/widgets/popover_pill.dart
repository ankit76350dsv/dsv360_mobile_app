import 'package:flutter/material.dart';

class PopoverPill extends StatelessWidget {
  final String label;
  final String value;
  final double? maxHeight;
  final bool allowWrap;
  final VoidCallback? onTap;

  const PopoverPill({
    super.key,
    required this.label,
    required this.value,
    this.maxHeight,
    this.allowWrap = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 12.0;
    const verticalPadding = 10.0;

    final valueText = Text(
      value,
      softWrap: allowWrap,
      maxLines: allowWrap ? 10 : 1,
      overflow: allowWrap ? TextOverflow.visible : TextOverflow.visible,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            if (onTap != null)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(Icons.open_in_new, size: 12, color: Colors.white70),
              ),
          ],
        ),
        const SizedBox(height: 6),
        valueText,
      ],
    );

    final child = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: content,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight ?? double.infinity),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.28), blurRadius: 10),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

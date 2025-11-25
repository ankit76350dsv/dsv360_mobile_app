// lib/views/profile/LabelValueText.dart
import 'package:flutter/material.dart';

class LabelValueText extends StatefulWidget {
  final String label;
  final String value;
  final int? charLimit; // inline truncation
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final double spacing;
  final bool enableToolkit;
  final IconData? toolkitIcon;

  const LabelValueText({
    super.key,
    required this.label,
    required this.value,
    this.charLimit,
    this.labelStyle,
    this.valueStyle,
    this.spacing = 8.0,
    this.enableToolkit = true,
    this.toolkitIcon,
  });

  @override
  State<LabelValueText> createState() => _LabelValueTextState();
}

class _LabelValueTextState extends State<LabelValueText> {
  OverlayEntry? _overlayEntry;
  final GlobalKey _targetKey = GlobalKey();

  String _inlineDisplay() {
    final v = widget.value;
    if (widget.charLimit == null) return v;
    if (v.length <= widget.charLimit!) return v;
    return v.substring(0, widget.charLimit!) + '...';
  }

  void _showPopover() {
    _removePopover();
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final RenderBox? targetRenderBox =
        _targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetRenderBox == null) return;

    final targetSize = targetRenderBox.size;
    final targetTopLeft = targetRenderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;
    final textScale = MediaQuery.of(context).textScaleFactor;

    // Tunables
    const horizontalScreenMargin = 12.0;
    const desiredPopoverMaxWidth = 320.0;
    const desiredPopoverMinWidth = 120.0;
    const containerPaddingHorizontal = 12.0 * 2; // left + right
    const gap = 8.0;

    // center x of the target
    final targetCenterX = targetTopLeft.dx + targetSize.width / 2;

    // vertical space available
    final spaceBelow =
        screenSize.height - (targetTopLeft.dy + targetSize.height) - horizontalScreenMargin;
    final spaceAbove = targetTopLeft.dy - horizontalScreenMargin;
    final showBelow = spaceBelow >= 80 || spaceBelow >= spaceAbove;

    // absolute max width (respect screen margins)
    final absoluteMaxWidth = (screenSize.width - horizontalScreenMargin * 2)
        .clamp(desiredPopoverMinWidth, desiredPopoverMaxWidth);

    // Styles used in popover for measurement
    final popLabelStyle = const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: Colors.white70,
    );
    final popValueStyle = const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );

    // Helper to measure intrinsic width (unconstrained)
    double measureIntrinsicWidth(String text, TextStyle style) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        textScaleFactor: textScale,
        maxLines: 1,
      );
      // layout with very large width so it computes intrinsic single-line width
      tp.layout(minWidth: 0, maxWidth: 10000);
      return tp.size.width;
    }

    final labelIntrinsicW = measureIntrinsicWidth(widget.label, popLabelStyle);
    final valueIntrinsicW = measureIntrinsicWidth(widget.value, popValueStyle);

    // Decide whether we can show value on single line:
    // If (valueIntrinsic + padding) <= absoluteMaxWidth -> single line
    final valueFitsSingleLine =
        (valueIntrinsicW + containerPaddingHorizontal) <= absoluteMaxWidth;

    // Content width we will use (intrinsic, but limited by absoluteMaxWidth - padding)
    final allowedContentMax = (absoluteMaxWidth - containerPaddingHorizontal).clamp(0.0, absoluteMaxWidth);

    final contentWidthCandidate = valueFitsSingleLine
        ? valueIntrinsicW // use real intrinsic width for short values
        : // if it doesn't fit on a single line, try to use the larger of label or allowed width
        (labelIntrinsicW > allowedContentMax ? allowedContentMax : allowedContentMax);

    // final content width must also be at least label intrinsic width (so label won't overflow)
    final contentWidth = contentWidthCandidate < labelIntrinsicW ? labelIntrinsicW : contentWidthCandidate;

    // final popover width = content + horizontal padding, clamped to allowed bounds
    double popoverWidth = (contentWidth + containerPaddingHorizontal)
        .clamp(desiredPopoverMinWidth, absoluteMaxWidth);

    // Determine if wrapping allowed (if we are at absoluteMaxWidth we must wrap)
    final allowWrap = popoverWidth >= absoluteMaxWidth && !valueFitsSingleLine ? true : false;

    // compute left so popover is centered on target but clamped into screen
    double left = targetCenterX - popoverWidth / 2;
    left = left.clamp(horizontalScreenMargin, screenSize.width - popoverWidth - horizontalScreenMargin);

    // compute vertical top and available height constraints
    final maxHeightIfBelow =
        (screenSize.height - (targetTopLeft.dy + targetSize.height) - horizontalScreenMargin)
            .clamp(48.0, screenSize.height);
    final maxHeightIfAbove = (targetTopLeft.dy - horizontalScreenMargin).clamp(48.0, screenSize.height);
    final popoverMaxHeight = showBelow ? maxHeightIfBelow : maxHeightIfAbove;

    double top;
    if (showBelow) {
      top = targetTopLeft.dy + targetSize.height + gap;
      final maxTop = screenSize.height - horizontalScreenMargin - 40.0;
      top = top.clamp(horizontalScreenMargin, maxTop);
    } else {
      top = (targetTopLeft.dy - gap - popoverMaxHeight).clamp(
        horizontalScreenMargin,
        screenSize.height - horizontalScreenMargin,
      );
    }

    _overlayEntry = OverlayEntry(builder: (ctx) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removePopover,
        child: Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              width: popoverWidth,
              child: Material(
                color: Colors.transparent,
                child: _PopoverPill(
                  label: widget.label,
                  value: widget.value,
                  maxHeight: popoverMaxHeight,
                  allowWrap: allowWrap,
                ),
              ),
            ),
          ],
        ),
      );
    });

    overlay.insert(_overlayEntry!);
  }

  void _removePopover() {
    try {
      _overlayEntry?.remove();
    } catch (_) {}
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removePopover();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inline = _inlineDisplay();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.label,
          style: widget.labelStyle ??
              const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
        ),
        SizedBox(width: widget.spacing),
        GestureDetector(
          key: _targetKey,
          onTap: () {
            if (!widget.enableToolkit) return;
            _showPopover();
          },
          child: ConstrainedBox(
            // restrict inline text so it doesn't overflow entire screen in narrow parents
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              inline,
              style: widget.valueStyle ?? const TextStyle(color: Colors.black54),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

class _PopoverPill extends StatelessWidget {
  final String label;
  final String value;
  final double? maxHeight;
  final bool allowWrap;

  const _PopoverPill({
    required this.label,
    required this.value,
    this.maxHeight,
    this.allowWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    // Keep padding identical to measurement logic
    const horizontalPadding = 12.0;
    const verticalPadding = 10.0;

    final valueText = Text(
      value,
      // If allowWrap is false -> single-line (no wrap)
      // If allowWrap is true -> wrap when needed
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 6),
        valueText,
      ],
    );

    // If wrapping is allowed and vertical space may be limited, wrap content in scroll.
    final child = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: content,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight ?? double.infinity),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.28), blurRadius: 10),
          ],
        ),
        child: child,
      ),
    );
  }
}

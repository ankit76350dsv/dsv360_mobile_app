import 'package:dsv360/features/profile/view/widgets/popover_pill.dart';
import 'package:flutter/material.dart';

class LabelValueText extends StatefulWidget {
  final String label;
  final String value;
  final int? charLimit;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final double spacing;
  final bool enableToolkit;
  final IconData? toolkitIcon;
  final VoidCallback? onPopoverTap;

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
    this.onPopoverTap,
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
    return '${v.substring(0, widget.charLimit!)}...';
  }

  void _showPopover() {
    _removePopover();
    final overlay = Overlay.of(context);

    final RenderBox? targetRenderBox =
        _targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetRenderBox == null) return;

    final targetSize = targetRenderBox.size;
    final targetTopLeft = targetRenderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;
    final textScale = MediaQuery.of(context).textScaleFactor;

    const horizontalScreenMargin = 12.0;
    const desiredPopoverMaxWidth = 320.0;
    const desiredPopoverMinWidth = 120.0;
    const containerPaddingHorizontal = 12.0 * 2;
    const gap = 8.0;

    final targetCenterX = targetTopLeft.dx + targetSize.width / 2;

    final spaceBelow =
        screenSize.height - (targetTopLeft.dy + targetSize.height) - horizontalScreenMargin;
    final spaceAbove = targetTopLeft.dy - horizontalScreenMargin;
    final showBelow = spaceBelow >= 80 || spaceBelow >= spaceAbove;

    final absoluteMaxWidth = (screenSize.width - horizontalScreenMargin * 2)
        .clamp(desiredPopoverMinWidth, desiredPopoverMaxWidth);

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

    double measureIntrinsicWidth(String text, TextStyle style) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        textScaleFactor: textScale,
        maxLines: 1,
      );
      tp.layout(minWidth: 0, maxWidth: 10000);
      return tp.size.width;
    }

    final labelIntrinsicW = measureIntrinsicWidth(widget.label, popLabelStyle);
    final valueIntrinsicW = measureIntrinsicWidth(widget.value, popValueStyle);

    final valueFitsSingleLine =
        (valueIntrinsicW + containerPaddingHorizontal) <= absoluteMaxWidth;

    final allowedContentMax =
        (absoluteMaxWidth - containerPaddingHorizontal).clamp(0.0, absoluteMaxWidth);

    final contentWidthCandidate = valueFitsSingleLine
        ? valueIntrinsicW
        : (labelIntrinsicW > allowedContentMax ? allowedContentMax : allowedContentMax);

    final contentWidth =
        contentWidthCandidate < labelIntrinsicW ? labelIntrinsicW : contentWidthCandidate;

    double popoverWidth =
        (contentWidth + containerPaddingHorizontal).clamp(desiredPopoverMinWidth, absoluteMaxWidth);

    final allowWrap = popoverWidth >= absoluteMaxWidth && !valueFitsSingleLine ? true : false;

    double left = targetCenterX - popoverWidth / 2;
    left = left.clamp(horizontalScreenMargin, screenSize.width - popoverWidth - horizontalScreenMargin);

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
                child: PopoverPill(
                  label: widget.label,
                  value: widget.value,
                  maxHeight: popoverMaxHeight,
                  allowWrap: allowWrap,
                  onTap: widget.onPopoverTap,
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

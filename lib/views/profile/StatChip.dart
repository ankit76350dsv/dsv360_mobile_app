import 'package:flutter/material.dart';

class StatChip extends StatefulWidget {
  final String name;
  final String value;
  final TextStyle nameStyle;
  final TextStyle valueStyle;
  final int maxLines;

  const StatChip({
    super.key,
    required this.name,
    required this.value,
    this.nameStyle = const TextStyle(fontWeight: FontWeight.w800),
    this.valueStyle = const TextStyle(color: Colors.black54),
    this.maxLines = 1,
  });

  @override
  State<StatChip> createState() => _StatChipState();
}


//! state chip......
class _StatChipState extends State<StatChip> {
  final GlobalKey _ellipsisKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  // popover settings (tweak as desired)
  static const double _popoverMaxWidth = 300;
  static const double _popoverMaxHeight = 220;
  static const double _screenPadding = 8.0;
  static const double _verticalGap = 8.0;
  static const double _horizontalContentPadding =
      12.0; // matches _buildPopover padding

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final RenderBox? targetRenderBox =
        _ellipsisKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context);
    if (targetRenderBox == null || overlay == null) return;

    final targetSize = targetRenderBox.size;
    final targetPos = targetRenderBox.localToGlobal(Offset.zero);

    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;

    // popover safe max width (responsive)
    final popoverSafeMaxWidth = (_popoverMaxWidth < screenWidth * 0.9)
        ? _popoverMaxWidth
        : screenWidth * 0.8;

    // style used for measurement (keep in sync with _buildPopover)
    final popoverTextStyle = const TextStyle(
      color: Colors.yellow,
      fontSize: 13,
    );

    // AVAILABLE width for text inside popover (after horizontal padding)
    final availableForText =
        popoverSafeMaxWidth - (_horizontalContentPadding * 2);

    // 1) Measure single-line width (no wrapping) to check if it fits on one line.
    final tpSingle = TextPainter(
      text: TextSpan(text: widget.value, style: popoverTextStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    tpSingle.layout(minWidth: 0, maxWidth: popoverSafeMaxWidth);
    final singleLineWidth = tpSingle.width;
    final singleLineHeight = tpSingle.height;

    bool forceSingleLine = false;
    double popoverWidth;
    double popoverHeight;

    // If full single-line width (plus padding) fits within our safe width, we prefer single-line.
    if (singleLineWidth + (_horizontalContentPadding * 2) <=
        popoverSafeMaxWidth) {
      forceSingleLine = true;
      popoverWidth = singleLineWidth + (_horizontalContentPadding * 2);
      popoverHeight = singleLineHeight + 20; // vertical padding 10+10
    } else {
      // 2) Otherwise measure with wrapping (allow multiple lines) using availableForText.
      final tpMulti = TextPainter(
        text: TextSpan(text: widget.value, style: popoverTextStyle),
        textDirection: TextDirection.ltr,
        maxLines: null, // allow wrapping measurement
      );
      tpMulti.layout(minWidth: 0, maxWidth: availableForText);

      final measuredTextWidth = tpMulti.width;
      final measuredTextHeight = tpMulti.height;

      popoverWidth = measuredTextWidth + (_horizontalContentPadding * 2);
      if (popoverWidth < 60) popoverWidth = 60;
      if (popoverWidth > popoverSafeMaxWidth)
        popoverWidth = popoverSafeMaxWidth;

      popoverHeight = measuredTextHeight + 20;
    }

    // clamp height to max
    if (popoverHeight > _popoverMaxHeight) popoverHeight = _popoverMaxHeight;

    // available space below and above the target
    final spaceBelow =
        screenHeight - (targetPos.dy + targetSize.height) - _screenPadding;
    final spaceAbove = (targetPos.dy) - _screenPadding;

    // decide preferred placement
    final bool preferBelow = spaceBelow >= 120 || spaceBelow >= spaceAbove;

    // compute top coordinate (clamped)
    double top;
    if (preferBelow && spaceBelow >= 80) {
      top = targetPos.dy + targetSize.height + _verticalGap;
      if (top + popoverHeight + _screenPadding > screenHeight) {
        top = screenHeight - popoverHeight - _screenPadding;
      }
    } else {
      top = targetPos.dy - popoverHeight - _verticalGap;
      if (top < _screenPadding) {
        top = (targetPos.dy + targetSize.height + _verticalGap).clamp(
          _screenPadding,
          screenHeight - popoverHeight - _screenPadding,
        );
      }
    }

    // center horizontally on target center, then clamp to screen edges
    final targetCenterX = targetPos.dx + targetSize.width / 2;
    double left = targetCenterX - popoverWidth / 2;
    if (left < _screenPadding) left = _screenPadding;
    if (left + popoverWidth + _screenPadding > screenWidth) {
      left = screenWidth - popoverWidth - _screenPadding;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _removeOverlay,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  left: left,
                  top: top,
                  width: popoverWidth,
                  child: _buildPopover(widget.value, forceSingleLine),
                ),
              ],
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildPopover(String fullText, bool forceSingleLine) {
    return Material(
      elevation: 8,
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: _horizontalContentPadding,
        ),
        constraints: const BoxConstraints(maxHeight: _popoverMaxHeight),
        child: SingleChildScrollView(
          child: forceSingleLine
              ? Text(
                  fullText,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                  style: const TextStyle(color: Colors.yellow, fontSize: 13),
                )
              : Text(
                  fullText,
                  softWrap: true,
                  style: const TextStyle(color: Colors.yellow, fontSize: 13),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.name, style: widget.nameStyle),
        const SizedBox(width: 6),
        Flexible(
          child: _TruncatingvalueWithAnchor(
            text: widget.value,
            textStyle: widget.valueStyle,
            maxLines: widget.maxLines,
            ellipsisKey: _ellipsisKey,
            onEllipsisTap: () {
              if (_overlayEntry == null) {
                _showOverlay();
              } else {
                _removeOverlay();
              }
            },
          ),
        ),
      ],
    );
  }
}







//! Truncating value that renders a tappable ellipsis using the provided key.
class _TruncatingvalueWithAnchor extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final int maxLines;
  final GlobalKey ellipsisKey;
  final VoidCallback onEllipsisTap;

  const _TruncatingvalueWithAnchor({
    required this.text,
    required this.textStyle,
    required this.maxLines,
    required this.ellipsisKey,
    required this.onEllipsisTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        final tp = TextPainter(
          text: TextSpan(text: text, style: textStyle),
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        );
        tp.layout(minWidth: 0, maxWidth: availableWidth);

        final fits = !tp.didExceedMaxLines;
        if (fits) {
          return Text(
            text,
            style: textStyle,
            maxLines: maxLines,
            overflow: TextOverflow.clip,
          );
        }

        final truncated = _truncateToFit(
          text,
          textStyle,
          availableWidth,
          maxLines,
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                truncated,
                style: textStyle,
                maxLines: maxLines,
                overflow: TextOverflow.clip,
              ),
            ),
            GestureDetector(
              key: ellipsisKey,
              onTap: onEllipsisTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '...',
                  style: textStyle.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _truncateToFit(
    String full,
    TextStyle style,
    double maxWidth,
    int maxLines,
  ) {
    if (full.isEmpty) return full;
    const ellipsis = '...';
    int low = 0;
    int high = full.length;
    String result = full;

    while (low <= high) {
      final mid = ((low + high) / 2).floor();
      final candidate = full.substring(0, mid).trimRight() + ellipsis;

      final tp = TextPainter(
        text: TextSpan(text: candidate, style: style),
        maxLines: maxLines,
        textDirection: TextDirection.ltr,
      );
      tp.layout(minWidth: 0, maxWidth: maxWidth);

      if (tp.didExceedMaxLines) {
        high = mid - 1;
      } else {
        result = candidate;
        low = mid + 1;
      }
    }

    return result;
  }
}

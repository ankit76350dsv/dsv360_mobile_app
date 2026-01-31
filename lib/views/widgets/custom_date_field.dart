import 'package:flutter/material.dart';

class CustomPickerField extends StatefulWidget {
  final String label;
  final String? valueText;
  final String placeholder;
  final VoidCallback onTap;
  final IconData icon;
  final bool enabled;

  const CustomPickerField({
    super.key,
    required this.label,
    required this.onTap,
    this.valueText,
    this.placeholder = 'Select',
    this.icon = Icons.calendar_today,
    this.enabled = true,
  });

  @override
  State<CustomPickerField> createState() => _CustomPickerFieldState();
}

class _CustomPickerFieldState extends State<CustomPickerField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final displayText =
        widget.valueText == null || widget.valueText!.isEmpty
            ? widget.placeholder
            : widget.valueText!;

    final isPlaceholder =
        widget.valueText == null || widget.valueText!.isEmpty;

    return InkWell(
      onTap: widget.enabled
          ? () {
              _focusNode.requestFocus();
              widget.onTap();
            }
          : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: InputDecorator(
          isFocused: _isFocused,
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(
              color: _isFocused
                  ? Colors.grey.withOpacity(0.9)
                  : Colors.grey.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: colors.secondary,
            enabled: widget.enabled,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.9),
                width: 2,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: Colors.grey.withOpacity(0.8),
              ),
              const SizedBox(width: 16),
              Text(
                displayText,
                style: TextStyle(
                  color: isPlaceholder
                      ? Colors.grey.withOpacity(0.7)
                      : colors.tertiary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

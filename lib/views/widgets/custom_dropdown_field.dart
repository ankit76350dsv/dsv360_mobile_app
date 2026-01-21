import 'package:flutter/material.dart';

class CustomDropDownField extends StatefulWidget {
  final List<DropdownMenuItem<String>> options;
  final String? selectedOption;
  final String hintText;
  final String labelText;
  final IconData prefixIcon;
  final ValueChanged<String?> onChanged;

  const CustomDropDownField({
    super.key,
    required this.options,
    this.selectedOption,
    required this.onChanged,
    required this.hintText,
    required this.labelText,
    required this.prefixIcon,
  });

  @override
  State<CustomDropDownField> createState() => _CustomDropDownFieldState();
}

class _CustomDropDownFieldState extends State<CustomDropDownField> {
  bool _isFocused = false;
  late FocusNode _focusNode;
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_updateFocusState);
    _selectedOption = widget.selectedOption;
  }

  @override
  void didUpdateWidget(covariant CustomDropDownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedOption != widget.selectedOption) {
      _selectedOption = widget.selectedOption;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_updateFocusState);
    _focusNode.dispose();
    super.dispose();
  }

  void _updateFocusState() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
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
      child: DropdownButtonFormField<String>(
        value: _selectedOption,
        hint: Text(
          widget.hintText,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: TextStyle(
          color: colors.tertiary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: colors.surface,
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: TextStyle(
            color: _isFocused
                ? Colors.grey.withOpacity(0.9)
                : Colors.grey.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: colors.secondary,
          prefixIcon: Icon(
            widget.prefixIcon,
            color: _isFocused
                ? Colors.grey.withOpacity(0.9)
                : Colors.grey.withOpacity(0.8),
            size: 20,
          ),
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ),
        ),
        items: widget.options,
        onChanged: (value) {
          setState(() => _selectedOption = value);
          widget.onChanged(value);
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '/core/constants/app_colors.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool isMultiline;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final IconData? prefixIcon;

  const CustomInputField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.isMultiline = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_updateFocusState);
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        enabled: widget.enabled,
        maxLines: widget.isMultiline ? (widget.maxLines ?? 5) : 1,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        focusNode: _focusNode,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: AppColors.textHint,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          labelText: widget.labelText,
          alignLabelWithHint: widget.isMultiline,
          labelStyle: TextStyle(
            color: _isFocused ? Colors.grey[400] : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: widget.prefixIcon != null && !widget.isMultiline
              ? Icon(
                  widget.prefixIcon,
                  color: _isFocused ? Colors.grey[400] : AppColors.textSecondary,
                  size: 20,
                )
              : null,
          prefixIconConstraints: widget.isMultiline 
              ? const BoxConstraints(minWidth: 0, minHeight: 0)
              : null,
          filled: true,
          fillColor: _isFocused
              ? AppColors.inputFill
              : AppColors.inputFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.inputBorder,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.inputBorder,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.grey[400]!,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.inputBorder,
              width: 1.5,
            ),
          ),
          contentPadding: widget.isMultiline
              ? const EdgeInsets.fromLTRB(18, 20, 18, 16)
              : const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
          errorStyle: const TextStyle(
            color: AppColors.error,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

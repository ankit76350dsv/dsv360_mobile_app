import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomInputSearch extends ConsumerStatefulWidget {
  final String hint;
  final StateProvider<String>? searchProvider;
  final ValueChanged<String>? onChanged;

  const CustomInputSearch({
    super.key,
    this.hint = "Search",
    this.searchProvider,
    this.onChanged,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CustomInputSearchState();
}

class _CustomInputSearchState extends ConsumerState<CustomInputSearch> {
  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;

    return TextField(
      onChanged: (value) {
        final text = value.trim();

        // 🔹 Update Riverpod provider if provided
        if (widget.searchProvider != null) {
          ref.read(widget.searchProvider!.notifier).state = text;
        }

        // 🔹 Call callback if provided
        widget.onChanged?.call(text);
      },
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: customColors.surfaceBackground,
        prefixIcon: Icon(Icons.search, color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

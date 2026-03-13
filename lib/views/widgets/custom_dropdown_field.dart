import 'package:dsv360/core/constants/theme.dart';
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
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final colorScheme = Theme.of(context).colorScheme;
    final listWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: TextStyle(
            color: Colors.grey.withOpacity(0.85),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          // Changed dropdown implementation to PopupMenuButton for better menu styling and responsiveness.
          child: PopupMenuButton<String>(
            color: customColors.cardBackground,
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.10),
            offset: const Offset(0, 8),
            constraints: BoxConstraints(minWidth: listWidth - 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colorScheme.outline.withOpacity(0.15),
                width: 1,
              ),
            ),
            onSelected: (value) {
              setState(() => _selectedOption = value);
              widget.onChanged(value);
            },
            itemBuilder: (context) {
              return widget.options.map((item) {
                final value = item.value;
                if (value == null) return const PopupMenuItem<String>(child: SizedBox.shrink());
                final isSelected = value == _selectedOption;
                final cs = Theme.of(context).colorScheme;
                return PopupMenuItem<String>(
                  value: value,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? Colors.blue.withOpacity(0.12)
                          : Theme.of(context).custom.cardBackground!,
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue.withOpacity(0.45)
                            : cs.outline.withOpacity(0.25),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        DefaultTextStyle.merge(
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.blue.shade400 : cs.onSurface,
                          ),
                          child: item.child,
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Colors.blue.shade400,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: customColors.inputFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    widget.prefixIcon,
                    size: 20,
                    color: Colors.grey.withOpacity(0.85),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedOption ?? widget.hintText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _selectedOption == null
                            ? Colors.grey
                            : customColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: customColors.textPrimary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

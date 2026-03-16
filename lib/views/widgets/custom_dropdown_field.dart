import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';

class CustomDropDownField extends StatefulWidget {
  final List<DropdownMenuItem<String>> options;
  final String? selectedOption;
  final String hintText;
  final String labelText;
  final IconData prefixIcon;
  final ValueChanged<String?> onChanged;
  final bool searchable;
  final String searchHintText;

  const CustomDropDownField({
    super.key,
    required this.options,
    this.selectedOption,
    required this.onChanged,
    required this.hintText,
    required this.labelText,
    required this.prefixIcon,
    this.searchable = false,
    this.searchHintText = 'Search',
  });

  @override
  State<CustomDropDownField> createState() => _CustomDropDownFieldState();
}

class _CustomDropDownFieldState extends State<CustomDropDownField> {
  String? _selectedOption;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  int _matchPriority(String text, String query) {
    final value = text.toLowerCase().trim();
    final q = query.toLowerCase().trim();

    if (q.isEmpty) return 99;
    if (value == q) return 0;
    if (value.startsWith(q)) return 1;
    if (value.contains(q)) return 2;
    return 3;
  }

  List<DropdownMenuItem<String>> _rankedItems(List<DropdownMenuItem<String>> items, String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return items;

    final filtered = items.where((item) {
      final value = (item.value ?? '').toLowerCase();
      return value.contains(q);
    }).toList();

    filtered.sort((a, b) {
      final aValue = (a.value ?? '').toLowerCase();
      final bValue = (b.value ?? '').toLowerCase();

      final priorityCompare = _matchPriority(aValue, q).compareTo(_matchPriority(bValue, q));
      if (priorityCompare != 0) return priorityCompare;

      final indexCompare = aValue.indexOf(q).compareTo(bValue.indexOf(q));
      if (indexCompare != 0) return indexCompare;

      return aValue.compareTo(bValue);
    });

    return filtered;
  }

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            offset: const Offset(0, 40),
            constraints: BoxConstraints(minWidth: listWidth -40),
            onOpened: () {
              if (widget.searchable) {
                _searchController.clear();
                _searchQuery = '';
              }
            },
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
              if (widget.searchable) {
                return [
                  PopupMenuItem<String>(
                    enabled: false,
                    padding: EdgeInsets.zero,
                    child: StatefulBuilder(
                      builder: (context, setMenuState) {
                        final rankedItems = _rankedItems(widget.options, _searchQuery);
                        final cs = Theme.of(context).colorScheme;

                        return SizedBox(
                          width: listWidth - 20,
                          height: 320,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: customColors.inputFill,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: cs.outline.withOpacity(0.20),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 8),
                                      Icon(Icons.search,
                                          size: 22,
                                          ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          autofocus: true,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: customColors.textPrimary,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: widget.searchHintText,
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                          ),
                                          onChanged: (value) {
                                            setMenuState(() {
                                              _searchQuery = value;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                ),
                              ),
                            
                              Expanded(
                                child: rankedItems.isEmpty
                                    ? Center(
                                        child: Text(
                                          'No matching results',
                                          style: TextStyle(color: cs.onSurfaceVariant),
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        itemCount: rankedItems.length,
                                        itemBuilder: (context, index) {
                                          final item = rankedItems[index];
                                          final value = item.value;
                                          if (value == null) return const SizedBox.shrink();
                                          final isSelected = value == _selectedOption;

                                          return InkWell(
                                            onTap: () {
                                              setState(() => _selectedOption = value);
                                              widget.onChanged(value);
                                              Navigator.of(context).pop();
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                color: isSelected
                                                    ? Colors.blue.withOpacity(0.12)
                                                    : Theme.of(context).custom.cardBackground!,
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: DefaultTextStyle.merge(
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: isSelected
                                                            ? FontWeight.w600
                                                            : FontWeight.w500,
                                                        color: isSelected
                                                            ? Colors.blue.shade400
                                                            : cs.onSurface,
                                                      ),
                                                      child: item.child,
                                                    ),
                                                  ),
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
                                        },
                                      ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ];
              }

              return widget.options.map((item) {
                final value = item.value;
                if (value == null) return const PopupMenuItem<String>(child: SizedBox.shrink());
                final isSelected = value == _selectedOption;
                final cs = Theme.of(context).colorScheme;
                return PopupMenuItem<String>(
                  value: value,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
                            ? const Color.fromARGB(255, 181, 221, 254).withOpacity(0.45)
                            : cs.outline.withOpacity(0.25),
                        width: 0,
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

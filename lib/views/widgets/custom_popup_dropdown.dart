import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';

class CustomPopupDropdown extends StatefulWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;
  final double iconSize; // optional icon size — defaults to 24 to match Flutter's Icon default

  const CustomPopupDropdown({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.icon,
    required this.onChanged,
    this.iconSize = 24,
  });

  @override
  State<CustomPopupDropdown> createState() => _CustomPopupDropdownState();
}

class _CustomPopupDropdownState extends State<CustomPopupDropdown> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _buttonKey = GlobalKey();
  List<String> _filteredItems = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showDropdownOverlay() {
    final customColors = Theme.of(_buttonKey.currentContext!).custom;
    setState(() {
      _filteredItems = widget.items;
      _searchController.clear();
    });

    final colors = Theme.of(_buttonKey.currentContext!).colorScheme;
    final RenderBox renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setOverlayState) => Stack(
          children: [
            // Full-screen barrier — onPanDown catches scrolls, onTap catches taps.
            // Being first in the Stack means touches on the panel (last child) don't reach it.
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeOverlay,
                onPanDown: (_) => _removeOverlay(),
                behavior: HitTestBehavior.opaque,
              ),
            ),
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 8,
              width: size.width,
              // opaque so touches stay inside the panel and never reach the barrier above.
              child: GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(14),
                    color: customColors.cardBackground,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      decoration: BoxDecoration(
                        color: customColors.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Search TextField
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              onChanged: (query) {
                                setOverlayState(() {
                                  if (query.isEmpty) {
                                    _filteredItems = widget.items;
                                  } else {
                                    _filteredItems = widget.items
                                        .where(
                                          (item) => item.toLowerCase().contains(
                                            query.toLowerCase(),
                                          ),
                                        )
                                        .toList();
                                  }
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: TextStyle(
                                  color: customColors.textHint,
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: customColors.textSecondary,
                                  size: 20,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: customColors.textSecondary,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setOverlayState(() {
                                            _searchController.clear();
                                            _filteredItems = widget.items;
                                          });
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: customColors.inputBorder!,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: customColors.inputBorder!,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: customColors.primary!,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                filled: true,
                                fillColor: customColors.cardBackground,
                                isDense: true,
                              ),
                              style: TextStyle(
                                color: customColors.textPrimary,
                                fontSize: 14,
                              ),
                              cursorColor: customColors.primary,
                            ),
                          ),
                          const Divider(height: 1),
                          // Scrollable List
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              itemCount: _filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];
                                final isSelected = item == widget.value;
                                return InkWell(
                                  onTap: () {
                                    widget.onChanged(item);
                                    _removeOverlay();
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? customColors.primary!.withOpacity(
                                              0.1,
                                            )
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        color: isSelected
                                            ? customColors.primary
                                            : customColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).custom;
    return GestureDetector(
      key: _buttonKey,
      onTap: _showDropdownOverlay,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: customColors.inputFill,
          border: Border.all(color: customColors.inputBorder!, width: 1.5),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: customColors.textSecondary, size: widget.iconSize),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.value ?? widget.hint,
                style: TextStyle(
                  color: widget.value == null
                      ? customColors.textHint
                      : customColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_drop_down, color: customColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

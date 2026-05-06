import 'package:dsv360/features/sprints/model/sprints_model.dart';
import 'package:flutter/material.dart';

Future<void> showCarryOverSprintSelectorDialog({
  required BuildContext context,
  required List<SprintModel> sprints,
  required String? currentSprintId,
  required Color cardBg,
  required Color textPrimary,
  required Color textSecondary,
  required Color greyBorder,
  required Color primary,
  required Future<void> Function(String carryOverSprintId) onConfirm,
}) async {
  String? selectedCarryOverSprintId;
  String query = '';

  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (dialogContext) {
      final maxHeight = MediaQuery.of(dialogContext).size.height * 0.6;

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredSprints = sprints.where((s) {
              final name = s.sprintName.toLowerCase();
              return name.contains(query.toLowerCase()) &&
                  s.rowId != currentSprintId;
            }).toList();

            return Container(
              constraints: BoxConstraints(maxHeight: maxHeight),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: greyBorder, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Text(
                      'Select Sprint to Carry Over Stories',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: TextField(
                      autofocus: true,
                      onChanged: (value) {
                        setDialogState(() => query = value);
                      },
                      style: TextStyle(color: textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search sprint...',
                        hintStyle: TextStyle(color: textSecondary, fontSize: 12),
                        isDense: true,
                        filled: true,
                        fillColor: cardBg,
                        prefixIcon: Icon(Icons.search, color: textSecondary, size: 18),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: greyBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: greyBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: greyBorder),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: filteredSprints.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'No sprints found',
                                style: TextStyle(color: textSecondary, fontSize: 13),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            itemCount: filteredSprints.length,
                            itemBuilder: (context, index) {
                              final sprint = filteredSprints[index];
                              final isSelected =
                                  selectedCarryOverSprintId == sprint.rowId;

                              return InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  setDialogState(() {
                                    selectedCarryOverSprintId = sprint.rowId;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 2),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: isSelected
                                        ? primary.withValues(alpha: 0.12)
                                        : Colors.transparent,
                                    border: isSelected
                                        ? Border.all(color: primary, width: 1)
                                        : null,
                                  ),
                                  child: Text(
                                    sprint.sprintName,
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: textSecondary, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: selectedCarryOverSprintId == null
                              ? null
                              : () async {
                                  Navigator.pop(dialogContext);
                                  await onConfirm(selectedCarryOverSprintId!);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            disabledBackgroundColor:
                                primary.withValues(alpha: 0.5),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

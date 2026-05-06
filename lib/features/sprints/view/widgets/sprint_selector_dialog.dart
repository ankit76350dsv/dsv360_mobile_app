import 'package:dsv360/features/sprints/model/sprints_model.dart';
import 'package:flutter/material.dart';

Future<void> showProjectSelectorDialog({
  required BuildContext context,
  required List<dynamic> projects,
  required String? selectedProjectName,
  required Color cardBg,
  required Color textPrimary,
  required Color textSecondary,
  required Color greyBorder,
  required Color primary,
  required void Function(dynamic project) onSelect,
}) async {
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
            final filteredProjects = projects.where((p) {
              final name = (p.projectName ?? '').toString().toLowerCase();
              return name.contains(query.toLowerCase());
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
                    child: TextField(
                      autofocus: true,
                      onChanged: (value) {
                        setDialogState(() => query = value);
                      },
                      style: TextStyle(color: textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search project...',
                        hintStyle: TextStyle(color: textSecondary, fontSize: 12),
                        isDense: true,
                        filled: true,
                        fillColor: cardBg,
                        prefixIcon: Icon(Icons.search, color: textSecondary, size: 18),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: greyBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: greyBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: greyBorder),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: filteredProjects.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'No projects found',
                                style: TextStyle(color: textSecondary, fontSize: 12),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            itemCount: filteredProjects.length,
                            itemBuilder: (context, index) {
                              final project = filteredProjects[index];
                              final isSelected =
                                  selectedProjectName == project.projectName;

                              return InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  onSelect(project);
                                  Navigator.pop(dialogContext);
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
                                  ),
                                  child: Text(
                                    project.projectName,
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
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Future<void> showSprintSelectorDialog({
  required BuildContext context,
  required List<SprintModel> sprints,
  required String? selectedSprintName,
  required Color cardBg,
  required Color textPrimary,
  required Color textSecondary,
  required Color greyBorder,
  required Color primary,
  required void Function(SprintModel sprint) onSelect,
}) async {
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
              return name.contains(query.toLowerCase());
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
                          horizontal: 10,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: greyBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: greyBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
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
                                style: TextStyle(color: textSecondary, fontSize: 12),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            itemCount: filteredSprints.length,
                            itemBuilder: (context, index) {
                              final sprint = filteredSprints[index];
                              final isSelected =
                                  selectedSprintName == sprint.sprintName;

                              return InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  onSelect(sprint);
                                  Navigator.pop(dialogContext);
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
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/widgets/circular_loader.dart';
import 'package:dsv360/core/widgets/warning_dialogue_box.dart';
import 'package:dsv360/features/badges/model/assigned_badge.dart';
import 'package:dsv360/features/badges/viewmodel/badges_viewmodel.dart';
import 'package:dsv360/features/users/model/users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserBadgesSheet extends ConsumerStatefulWidget {
  const UserBadgesSheet({super.key, required this.user});

  final UsersModel user;

  @override
  ConsumerState<UserBadgesSheet> createState() => _UserBadgesSheetState();
}

class _UserBadgesSheetState extends ConsumerState<UserBadgesSheet> {
  late Future<List<AssignedBadge>> _badgesFuture;
  String? _deletingRowId;

  @override
  void initState() {
    super.initState();
    _badgesFuture = _fetchUserBadges();
  }

  Future<List<AssignedBadge>> _fetchUserBadges() {
    return ref
        .read(userBadgesViewModelProvider)
        .fetchUserBadges(widget.user.userId);
  }

  Future<void> _deleteAssignedBadge(AssignedBadge badge) async {
    if (_deletingRowId != null) return;

    final confirmed = await showWarningDialogueBox<bool>(
      context: context,
      title: 'Delete Badge',
      subtitle: 'Are you sure you want to delete this badge?',
      primaryText: 'Delete',
    );

    if (confirmed != true) return;

    setState(() {
      _deletingRowId = badge.rowId;
    });

    try {
      await ref.read(userBadgesViewModelProvider).deleteAssignedBadge(badge.rowId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Badge deleted successfully')),
      );

      setState(() {
        _badgesFuture = _fetchUserBadges();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete badge')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _deletingRowId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AssignedBadge>>(
      future: _badgesFuture,
      builder: (context, snapshot) {
        // Calculate dynamic sheet height based on badge count
        final badges = snapshot.data ?? const <AssignedBadge>[];
        final badgeCount = badges.length;
        
        // Calculate initial fraction based on badge count
        double initialFraction;
        if (badgeCount == 0) {
          initialFraction = 0.25;
        } else if (badgeCount <= 3) {
          initialFraction = 0.40;
        } else if (badgeCount <= 6) {
          initialFraction = 0.65;
        } else {
          initialFraction = 0.70;
        }

        final colors = Theme.of(context).colorScheme;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: initialFraction,
          minChildSize: 0.25,
          maxChildSize: 1,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 14, bottom: 12),
                    alignment: Alignment.center,
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Theme.of(context).custom.primary!.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Text(
                    "${widget.user.firstName}'s Badges",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Expanded(child: Center(child: CircularLoader()))
                  else if (snapshot.hasError)
                    Expanded(
                      child: Center(
                        child: Text(
                          snapshot.error.toString(),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                  else if (badges.isEmpty)
                    const Expanded(child: Center(child: Text('No badges assigned')))
                  else
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: GridView.builder(
                          controller: scrollController,
                          itemCount: badges.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: 0.65,
                              ),
                          itemBuilder: (context, index) {
                            final badge = badges[index];

                            return Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Image.network(
                                            badge.badgeLogo,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => const Icon(
                                              Icons.verified,
                                              color: Colors.greenAccent,
                                              size: 36,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: _deletingRowId == badge.rowId
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularLoader(),
                                                )
                                              : PopupMenuButton<String>(
                                                  icon: const Icon(Icons.more_vert, size: 18),
                                                  color: colors.surface,
                                                  elevation: 8,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                    side: BorderSide(
                                                      color: colors.outline.withValues(alpha: 0.3),
                                                      width: 0.3,
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  onSelected: (value) {
                                                    if (value == 'delete') {
                                                      _deleteAssignedBadge(badge);
                                                    }
                                                  },
                                                  itemBuilder: (context) => [
                                                    const PopupMenuItem<String>(
                                                      value: 'delete',
                                                      child: Text(
                                                        'Delete Badge',
                                                        style: TextStyle(color: Colors.red),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  badge.badgeName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: colors.onSurface),
                                ),
                                Text(
                                  badge.badgeLevel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).custom.primary,
                              foregroundColor: colors.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'CLOSE',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

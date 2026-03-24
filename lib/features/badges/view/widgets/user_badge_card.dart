import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/models/users.dart';
import 'package:dsv360/features/badges/view/widgets/user_badges_sheet.dart';
import 'package:flutter/material.dart';

class UserBadgeCard extends StatelessWidget {
  const UserBadgeCard({super.key, required this.user});

  final UsersModel user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {},
      child: Card(
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.6),
        
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${user.firstName} ${user.lastName}',
                              style: theme.textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                           
                            const SizedBox(height: 8.0),
                            _userInfoRow(context, Icons.email, user.emailAddress),
                            _userInfoRow(context, Icons.tag, 'U${user.userId.length >4 ? user.userId.substring(user.userId.length - 4) : user.userId }'),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => _openUserBadges(context),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Theme.of(context).custom.logoColor!,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.emoji_events_outlined,
                                size: 18,
                                color: Theme.of(context).custom.logoColor!,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'BADGES',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                  color: Theme.of(context).custom.logoColor!,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userInfoRow(BuildContext context, IconData icon, String text) {
    final customColors = Theme.of(context).custom;

    return Row(
      children: [
        Icon(icon, size: 18, color: customColors.textSecondary, ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: customColors.textSecondary, fontWeight: FontWeight.bold,),
          ),
        ),
      ],
    );
  }

  void _openUserBadges(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => UserBadgesSheet(user: user),
    );
  }
}

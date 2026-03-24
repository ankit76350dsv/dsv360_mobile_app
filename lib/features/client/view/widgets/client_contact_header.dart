import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/client/model/client_contacts.dart';
import 'package:dsv360/views/widgets/custom_card_button.dart';
import 'package:flutter/material.dart';

class ClientContactHeader extends StatelessWidget {
  final ClientContacts clientContacts;
  final VoidCallback onDelete;
  final bool isDeleting;

  const ClientContactHeader({
    super.key,
    required this.clientContacts,
    required this.onDelete,
    required this.isDeleting,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.custom;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: customColors.primary!.withOpacity(0.15),
                  child: Icon(
                    Icons.filter_alt,
                    size: 22,
                    color: customColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${clientContacts.firstName} ${clientContacts.lastName}',
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        clientContacts.orgName,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CustomCardButton(
            onTap: isDeleting ? () {} : onDelete,
            icon: Icons.delete,
            color: customColors.error,
          ),
        ],
      ),
    );
  }
}

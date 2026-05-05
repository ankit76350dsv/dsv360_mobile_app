import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/accounts/model/accounts.dart';
import 'package:dsv360/features/accounts/view/pages/add_edit_accounts.dart';
import 'package:dsv360/features/accounts/viewmodel/delete_account_viewmodel.dart';
import 'package:dsv360/features/accounts/view/widgets/account_row.dart';
import 'package:dsv360/features/accounts/view/widgets/show_delete_dialoge.dart';
import 'package:dsv360/features/accounts/view/widgets/website_row.dart';
import 'package:dsv360/core/widgets/custom_card_button.dart';
import 'package:dsv360/core/widgets/custom_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountsCard extends ConsumerStatefulWidget {
  final Account account;
  const AccountsCard({super.key, required this.account});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountsCardState();
}

class _AccountsCardState extends ConsumerState<AccountsCard> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.custom;

    return GestureDetector(
      onTap: () {},
      child: Card(
        elevation: 4,
        shadowColor: Colors.black26,
        
        
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.5),
          
        ),
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
              child: Expanded(
                child: Text(
                  widget.account.orgName,
                  style: theme.textTheme.cardTitle, 
                  softWrap: true,
                  
                  
                ),
              ),
            ),

            // Divider
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.withValues(alpha: 0.2),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
              child: AccountRow(icon: Icons.email, value:widget.account.email),
            ),
                          
            
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              WebsiteRow(
                              icon: Icons.web_sharp,
                              value: widget.account.website,
                            ),
                              AccountRow(
                                icon:Icons.tag,
                                value:'C${widget.account.rowId.length > 4 ? widget.account.rowId.substring(widget.account.rowId.length - 4) : widget.account.rowId}',
                              ),
                          ],
                        ),
                      ),
                      
                      
                    ],
                  ),
                  
                  Divider(color: customColors.surfaceBackground!),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              CustomChip(
                                label: widget.account.orgType,
                                color: customColors.primary!,
                                icon: null,
                              ),
                              const SizedBox(width: 6.0),
                              CustomChip(
                                label: widget.account.status,
                                color: customColors.primary!,
                                icon: Icons.add_comment_outlined,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(width: 6,),

                          Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomCardButton(
                            onTap: () {
                              // run function

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEditAccountsPage(
                                    account: widget.account,
                                  ),
                                ),
                              );
                            },
                            icon: Icons.edit,
                          ),
                          const SizedBox(width: 5.0),
                          CustomCardButton(
                            onTap: () {
                              //do nothing for the moment

                              showDeleteDialoge(
                                context: context,
                                ref: ref,
                                orgName: widget.account.orgName,
                                rowId: widget.account.rowId,
                                onDelete: (rowId) => ref
                                    .read(deleteAccountViewModelProvider)
                                    .deleteAccountWithFallback(
                                      context: context,
                                      rowId: rowId,
                                    ),
                              );
                            },
                            icon: Icons.delete,
                            color: customColors.error,
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

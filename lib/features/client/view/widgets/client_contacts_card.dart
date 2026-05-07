import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:dsv360/core/widgets/warning_dialogue_box.dart';
import 'package:dsv360/features/client/model/client_contacts.dart';
import 'package:dsv360/features/client/repositories/client_contacts_repository.dart';
import 'package:dsv360/features/client/view/widgets/client_contact_header.dart';
import 'package:dsv360/features/client/view/widgets/client_info_row.dart';
import 'package:dsv360/features/client/view/widgets/client_status_switch.dart';
import 'package:dsv360/features/client/viewmodel/client_contact_actions_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientContactsCard extends ConsumerStatefulWidget {
  final ClientContacts clientContacts;
  const ClientContactsCard({super.key, required this.clientContacts});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ClientContactsCardState();
}

class _ClientContactsCardState extends ConsumerState<ClientContactsCard>
    with SingleTickerProviderStateMixin {
  late bool clientStatus;
  bool _isUpdatingStatus = false;
  bool _isDeleting = false;

  late final AnimationController _dotController;
  late final List<Animation<double>> _dotScales;

  static const _dotCount = 3;
  static const _cycleDuration = Duration(milliseconds: 900);

  @override
  void initState() {
    super.initState();
    clientStatus = widget.clientContacts.status;

    _dotController = AnimationController(
      vsync: this,
      duration: _cycleDuration,
    )..repeat();

    _dotScales = List.generate(_dotCount, (i) => _buildDotAnimation(i));
  }

  Animation<double> _buildDotAnimation(int index) {
    const activeFraction = 0.55;
    final offset = index / _dotCount;

    const restScale = 0.65;
    const peakScale = 1.4;

    final beforeFlat = offset;
    final riseLen = activeFraction / 2;
    final fallLen = activeFraction / 2;
    final afterFlat = 1.0 - offset - activeFraction;

    if (afterFlat < 0) {
      final clampedFall = 1.0 - offset - riseLen;
      return TweenSequence<double>([
        if (beforeFlat > 0.001)
          TweenSequenceItem(
            tween: ConstantTween(restScale),
            weight: beforeFlat,
          ),
        TweenSequenceItem(
          tween: Tween(begin: restScale, end: peakScale)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: riseLen,
        ),
        TweenSequenceItem(
          tween: Tween(begin: peakScale, end: restScale)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: clampedFall.clamp(0.001, 1.0),
        ),
      ]).animate(_dotController);
    }

    return TweenSequence<double>([
      if (beforeFlat > 0.001)
        TweenSequenceItem(
          tween: ConstantTween(restScale),
          weight: beforeFlat,
        ),
      TweenSequenceItem(
        tween: Tween(begin: restScale, end: peakScale)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: riseLen,
      ),
      TweenSequenceItem(
        tween: Tween(begin: peakScale, end: restScale)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: fallLen,
      ),
      if (afterFlat > 0.001)
        TweenSequenceItem(
          tween: ConstantTween(restScale),
          weight: afterFlat,
        ),
    ]).animate(_dotController);
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ClientContactsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isUpdatingStatus &&
        oldWidget.clientContacts.status != widget.clientContacts.status) {
      clientStatus = widget.clientContacts.status;
    }
  }

  Future<void> _confirmAndUpdateStatus(bool newStatus) async {
    if (_isUpdatingStatus) return;

    final fullName =
        '${widget.clientContacts.firstName} ${widget.clientContacts.lastName}';
    final action =
        newStatus ? 'set status to Active' : 'set status to Inactive';

    final confirmed = await showWarningDialogueBox<bool>(
      context: context,
      title: 'Change Client Status',
      subtitle: 'Are you sure you want to $action "$fullName"?',
      primaryText: 'CONFIRM',
    );

    if (confirmed != true) return;

    final previous = clientStatus;
    setState(() {
      clientStatus = newStatus;
      _isUpdatingStatus = true;
    });

    try {
      await ref
          .read(clientContactActionsViewModelProvider)
          .updateClientStatusWithFallback(
            newStatus: newStatus,
            rowId: widget.clientContacts.rowId,
            userId: widget.clientContacts.userId,
          );
      if (!mounted) return;

      ref.invalidate(clientContactsListRepositoryProvider);
      
      showSuccessSnackBar(context, 'Client status updated to ${newStatus ? 'Active' : 'Inactive'} successfully');
    } catch (e) {
      if (!mounted) return;
      setState(() => clientStatus = previous);
      
      showErrorSnackBar(context, 'Failed to update client status');
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  Future<void> _confirmAndDeleteClient() async {
    if (_isDeleting) return;

    final fullName =
        '${widget.clientContacts.firstName} ${widget.clientContacts.lastName}';
    final confirmed = await showWarningDialogueBox<bool>(
      context: context,
      title: 'Delete Client Contact',
      subtitle: 'Are you sure you want to delete "$fullName"?',
      primaryText: 'DELETE',
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      await ref.read(clientContactActionsViewModelProvider).deleteClientContact(
            rowId: widget.clientContacts.rowId,
            userId: widget.clientContacts.userId,
          );
      if (!mounted) return;
      ref.invalidate(clientContactsListRepositoryProvider);
      
      showSuccessSnackBar(context, 'Client contact deleted successfully');
    } catch (e) {
      if (!mounted) return;
      
      showErrorSnackBar(context, 'Failed to delete client contact');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.custom;

    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Card(
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClientContactHeader(
                  clientContacts: widget.clientContacts,
                  onDelete: _confirmAndDeleteClient,
                  isDeleting: _isDeleting,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.2),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                  child: Column(
                    children: [
                      ClientInfoRow(
                        icon: Icons.tag,
                        text:
                            'C${widget.clientContacts.userId.length > 5 ? widget.clientContacts.userId.substring(widget.clientContacts.userId.length - 5) : widget.clientContacts.userId}',
                      ),
                      ClientInfoRow(
                        icon: Icons.email,
                        text: widget.clientContacts.email,
                      ),
                      ClientInfoRow(
                        icon: Icons.phone,
                        text: widget.clientContacts.phone,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 10),
                      ClientStatusSwitch(
                        value: clientStatus,
                        isUpdatingStatus: _isUpdatingStatus,
                        onChanged: _confirmAndUpdateStatus,
                        dotCount: _dotCount,
                        dotScales: _dotScales,
                        loaderColor: customColors.primary ??
                            Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

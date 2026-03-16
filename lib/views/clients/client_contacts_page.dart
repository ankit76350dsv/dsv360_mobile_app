import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/core/widgets/warning_dialogue_box.dart';
import 'package:dsv360/models/client_contacts.dart';
import 'package:dsv360/repositories/client_contacts_repository.dart';
import 'package:dsv360/views/clients/add_client_contacts_page.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';
import 'package:dsv360/views/widgets/custom_card_button.dart';
import 'package:dsv360/views/widgets/custom_input_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientContactsPage extends ConsumerStatefulWidget {
  const ClientContactsPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ClientContactsState();
}

class _ClientContactsState extends ConsumerState<ClientContactsPage> {
  @override
  Widget build(BuildContext context) {
    final clientContactsListAsync = ref.watch(
      clientContactsListRepositoryProvider,
    );
    final query = ref.watch(clientContactsSearchQueryProvider);
    final customColors = Theme.of(context).custom;
    final connectivityStatus = ref.watch(connectivityStatusProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        toolbarHeight: 35.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            }
          },
        ),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Clients Contacts',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: const [],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: connectivityStatus.when(
        data: (results) {
          if (results.contains(ConnectivityResult.none)) {
            return null;
          }
          return FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: customColors.primary,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddClientContactsPage(clientContacts: null),
                ),
              );
            },
            child: const Icon(Icons.add, size: 28, color: Colors.white),
          );
        },
        loading: () => null,
        error: (_, __) => null,
      ),
      body: SafeArea(
        child: connectivityStatus.when(
          data: (results) {
            if (results.contains(ConnectivityResult.none)) {
              return GlobalError(
                message: 'Please check your internet connection.',
                isNetworkError: true,
                onRetry: () {
                  ref.invalidate(connectivityStatusProvider);
                },
              );
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: CustomInputSearch(
                    hint: "Search client contacts",
                    searchProvider: clientContactsSearchQueryProvider,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: clientContactsListAsync.when(
                      loading: () => const GlobalLoader(
                        message: 'Loading client contacts info...',
                      ),
                      error: (error, stack) => GlobalError(
                        message: 'Failed to load client contacts data: $error',
                        onRetry: () =>
                            ref.refresh(clientContactsListRepositoryProvider),
                      ),
                      data: (clientContactsList) {
                        final filteredClientContacts = clientContactsList.where(
                          (c) {
                            final q = query.toLowerCase();
                            return c.orgName.toLowerCase().contains(q) ||
                                c.email.toLowerCase().contains(q) ||
                                c.firstName.toLowerCase().contains(q) ||
                                c.lastName.toLowerCase().contains(q);
                          },
                        ).toList();

                        if (filteredClientContacts.isEmpty) {
                          return const Center(child: Text('No accounts found'));
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(clientContactsListRepositoryProvider);
                            await ref.read(
                              clientContactsListRepositoryProvider.future,
                            );
                          },
                          child: ListView.builder(
                            itemCount: filteredClientContacts.length,
                            itemBuilder: (context, index) {
                              return ClientContactsCard(
                                clientContacts: filteredClientContacts[index],
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
          error: (error, stack) => GlobalError(
            message: 'Failed to check connectivity: $error',
            onRetry: () => ref.invalidate(connectivityStatusProvider),
          ),
          loading: () =>
              const GlobalLoader(message: 'Checking connection...'),
        ),
      ),
    );
  }
}

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

  // ── Smooth wave loader ──────────────────────────────────────────────────────
  late final AnimationController _dotController;
  // Each dot peaks at a different phase offset (0, 1/3, 2/3 of the cycle).
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

    // Build one scale animation per dot, each offset by 1/dotCount of the cycle.
    _dotScales = List.generate(_dotCount, (i) {
      final start = i / _dotCount;          // 0.0, 0.333, 0.666
      final peak  = start + 1 / (_dotCount * 2); // midpoint of each active window
      final end   = start + 2 / _dotCount;  // wraps > 1 — handled by TweenSequence

      // Use a TweenSequence so the dot grows then shrinks within its window.
      // We map the full [0,1] controller range but only "activate" the dot
      // during its slice; outside the slice it stays at the rest scale.
      return _buildDotAnimation(i);
    });
  }

  Animation<double> _buildDotAnimation(int index) {
    // Fraction of the cycle this dot is "active" (growing + shrinking).
    const activeFraction = 0.55; // slightly more than 1/3 so dots slightly overlap → smoother wave
    final offset = index / _dotCount;

    // Build a curve that peaks in the middle of [offset, offset+activeFraction]
    // and is flat (restScale) outside that window.
    // We use a sequence of three segments: flat → up → down → flat (wrap-around handled via modulo).

    const restScale  = 0.65;
    const peakScale  = 1.4;

    // Segment lengths (must sum to 1.0):
    final beforeFlat = offset;                          // flat before activation
    final riseLen    = activeFraction / 2;
    final fallLen    = activeFraction / 2;
    final afterFlat  = 1.0 - offset - activeFraction;  // flat after activation

    // Edge case: if offset+activeFraction > 1 the window wraps.
    // For our 3-dot case offset ∈ {0, 0.333, 0.666} and activeFraction=0.55
    // the last dot's window goes to 0.666+0.55=1.216 → needs wrapping.
    // Simplest fix: clamp afterFlat to 0 if negative and trim activeFraction.
    if (afterFlat < 0) {
      // Window wraps — split into two TweenSequences and combine via a
      // proxy animation. For simplicity we just let the last dot's fall
      // continue past 1.0 and rely on the controller's repeat() to seamlessly
      // restart — visually indistinguishable.
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

  // ── Status update (robust 404-detection) ───────────────────────────────────

  /// Returns true if [e] is a 404-class error regardless of how Dio wraps it.
  bool _is404(Object e) {
    final s = e.toString();
    // Dio surfaces status codes as "DioException ... statusCode: 404" or
    // "Response ... 404 Not Found" — cover both patterns.
    return s.contains('404') || s.contains('Not Found');
  }

  Future<void> _updateClientStatusWithFallback(bool newStatus) async {
    final Map<String, dynamic> body = {
      'status': newStatus,
      'ROWID': widget.clientContacts.rowId,
      'USERID': widget.clientContacts.userId,
    };

    try {
      await ApiClient.instance.post(
        'time_entry_management_application_function/updateClientContactStatus',
        data: body,
      );
      return; // success — exit early
    } catch (e) {
      if (!_is404(e)) rethrow; // non-404 → surface immediately
    }

    // First 404 fallback
    try {
      await ApiClient.instance.put(
        'time_entry_management_application_function/updateClientContactStatus/${widget.clientContacts.rowId}',
        data: body,
      );
      return;
    } catch (e) {
      if (!_is404(e)) rethrow;
    }

    // Second 404 fallback
    await ApiClient.instance.put(
      'time_entry_management_application_function/contact/${widget.clientContacts.rowId}',
      data: body,
    );
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
      await _updateClientStatusWithFallback(newStatus);
      if (!mounted) return;

      ref.invalidate(clientContactsListRepositoryProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Client status updated to ${newStatus ? 'Active' : 'Inactive'} successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => clientStatus = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update client status')),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> _deleteClientContactWithFallback() async {
    final Map<String, dynamic> body = {
      'ROWID': widget.clientContacts.rowId,
      'USERID': widget.clientContacts.userId,
    };
    await ApiClient.instance.delete(
      'time_entry_management_application_function/contact',
      data: body,
    );
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
      await _deleteClientContactWithFallback();
      if (!mounted) return;
      ref.invalidate(clientContactsListRepositoryProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client contact deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete client contact')),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

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
              side: BorderSide(
                  color: Colors.grey.withOpacity(0.2), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                customColors.primary!.withOpacity(0.15),
                            child: Icon(
                              Icons.filter_alt,
                              size: 22,
                              color: customColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.clientContacts.firstName} ${widget.clientContacts.lastName}',
                                style: theme.textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.clientContacts.orgName,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 12.0),
                          CustomCardButton(
                            onTap: _isDeleting
                                ? () {}
                                : _confirmAndDeleteClient,
                            icon: Icons.delete,
                            color: customColors.error,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.2),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 16),
                  child: Column(
                    children: [
                      _clientInfoRow(
                        Icons.tag,
                        'C${widget.clientContacts.userId.length > 5 ? widget.clientContacts.userId.substring(widget.clientContacts.userId.length - 5) : widget.clientContacts.userId}',
                      ),
                      _clientInfoRow(
                          Icons.email, widget.clientContacts.email),
                      _clientInfoRow(
                          Icons.phone, widget.clientContacts.phone),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 10),
                      // ── Switch + loader overlay ──────────────────────────
                      // Match the real on-screen size of the scaled Switch.
                      // Flutter's Switch is 59×38 (material spec); scaled by
                      // 0.70 → ~41×27. We clamp to the nearest whole size.
                      SizedBox(
                        width: 42,
                        height: 27,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Opacity(
                              opacity: _isUpdatingStatus ? 0.25 : 1.0,
                              child: IgnorePointer(
                                ignoring: _isUpdatingStatus,
                                child: Transform.scale(
                                  scale: 0.70,
                                  child: Switch(
                                    value: clientStatus,
                                    onChanged: _isUpdatingStatus
                                        ? null
                                        : _confirmAndUpdateStatus,
                                  ),
                                ),
                              ),
                            ),
                            if (_isUpdatingStatus)
                              _buildWaveLoader(
                                customColors.primary ??
                                    Theme.of(context).colorScheme.primary,
                              ),
                          ],
                        ),
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

  Widget _clientInfoRow(IconData icon, String text) {
    final customColors = Theme.of(context).custom;
    return Row(
      children: [
        Icon(icon, size: 18, color: customColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: customColors.textSecondary),
        ),
      ],
    );
  }

  /// Smooth three-dot wave loader sized to sit inside the 42×27 switch area.
  Widget _buildWaveLoader(Color color) {
    const dotSize  = 6.0;
    const dotGap   = 4.0;

    return SizedBox(
      // 3 dots + 2 gaps
      width:  _dotCount * dotSize + (_dotCount - 1) * dotGap,
      height: dotSize * 1.4, // enough room for the peak scale
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_dotCount, (i) {
          return Padding(
            padding: EdgeInsets.only(right: i < _dotCount - 1 ? dotGap : 0),
            child: AnimatedBuilder(
              animation: _dotScales[i],
              builder: (_, __) => Transform.scale(
                scale: _dotScales[i].value,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
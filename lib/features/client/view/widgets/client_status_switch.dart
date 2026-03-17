import 'package:dsv360/features/client/view/widgets/wave_loader.dart';
import 'package:flutter/material.dart';

class ClientStatusSwitch extends StatelessWidget {
  final bool value;
  final bool isUpdatingStatus;
  final ValueChanged<bool>? onChanged;
  final int dotCount;
  final List<Animation<double>> dotScales;
  final Color loaderColor;

  const ClientStatusSwitch({
    super.key,
    required this.value,
    required this.isUpdatingStatus,
    required this.onChanged,
    required this.dotCount,
    required this.dotScales,
    required this.loaderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 27,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: isUpdatingStatus ? 0.25 : 1.0,
            child: IgnorePointer(
              ignoring: isUpdatingStatus,
              child: Transform.scale(
                scale: 0.70,
                child: Switch(
                  value: value,
                  onChanged: isUpdatingStatus ? null : onChanged,
                ),
              ),
            ),
          ),
          if (isUpdatingStatus)
            WaveLoader(
              dotCount: dotCount,
              dotScales: dotScales,
              color: loaderColor,
            ),
        ],
      ),
    );
  }
}

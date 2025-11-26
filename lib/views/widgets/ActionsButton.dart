// // lib/main.dart
// import 'package:flutter/material.dart';

// enum ActionButtonType { tag, filled }

// class ActionsButton extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final VoidCallback? onTap;

//   // Style for tag button
//   final Color tagTextColor;
//   final Color tagBackgroundColor;
//   final Color tagBorderColor;

//   // Style for filled button
//   final Color filledTextColor;
//   final Color filledBackgroundColor;

//   final double width;
//   final ActionButtonType type;

//   const ActionsButton({
//     super.key,
//     required this.label,
//     required this.icon,
//     this.onTap,
//     this.type = ActionButtonType.tag, // default small button
//     // Tag style defaults
//     this.tagTextColor = const Color(0xFFEA8B3D),
//     this.tagBackgroundColor = const Color(0xFFFFF2E5),
//     this.tagBorderColor = const Color(0xFFF6CFAA),

//     // Filled style defaults
//     this.filledTextColor = Colors.white,
//     this.filledBackgroundColor = const Color(0xFF154BA8),

//     this.width = 220, // used only for filled type
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (type == ActionButtonType.filled) {
//       // ==== FILLED BUTTON STYLE ====
//       return SizedBox(
//         width: width,
//         child: ElevatedButton.icon(
//           onPressed: onTap,
//           icon: Icon(icon, size: 18, color: filledTextColor),
//           label: Text(
//             label,
//             style: TextStyle(
//               fontWeight: FontWeight.w700,
//               color: filledTextColor,
//               fontSize: 14,
//             ),
//           ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: filledBackgroundColor,
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             elevation: 6,
//             shadowColor: Colors.black26,
//           ),
//         ),
//       );
//     }

//     // ==== TAG BUTTON STYLE ====
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: tagBackgroundColor,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: tagBorderColor),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 12, color: tagTextColor),
//           const SizedBox(width: 4),
//           Text(
//             label,
//             style: TextStyle(
//               color: tagTextColor,
//               fontWeight: FontWeight.w700,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

enum ActionButtonType { tag, filled }

class ActionsButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  // Tag style
  final Color tagTextColor;
  final Color tagBackgroundColor;
  final Color tagBorderColor;

  // Filled style
  final Color filledTextColor;
  final Color filledBackgroundColor;

  /// If provided -> button uses this width.
  /// If null -> button will expand to parent's width when parent provides finite width,
  /// otherwise it will size to its intrinsic width (so it won't break in Row).
  final double? width;

  final ActionButtonType type;

  const ActionsButton({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.type = ActionButtonType.tag,
    // Tag defaults
    this.tagTextColor = const Color(0xFFEA8B3D),
    this.tagBackgroundColor = const Color(0xFFFFF2E5),
    this.tagBorderColor = const Color(0xFFF6CFAA),
    // Filled defaults
    this.filledTextColor = Colors.white,
    this.filledBackgroundColor = const Color(0xFF154BA8),
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (type == ActionButtonType.filled) {
      // final elevated = ElevatedButton.icon(
      //   onPressed: onTap,
      //   icon: Icon(icon, size: 18, color: filledTextColor),
      //   label: Text(
      //     label,
      //     style: TextStyle(
      //       fontWeight: FontWeight.w700,
      //       color: filledTextColor,
      //       fontSize: 14,
      //     ),
      //   ),
      //   style: ElevatedButton.styleFrom(
      //     // backgroundColor: filledBackgroundColor,
      //     border: Border.all(color: tagBorderColor),
      //     padding: const EdgeInsets.symmetric(vertical: 12),
      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //     elevation: 6,
      //     shadowColor: Colors.black26,
      //   ),
      // );
      final elevated = ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: filledTextColor),
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: filledTextColor,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          elevation: 6,
          shadowColor: Colors.black26,

          // ✅ Move border inside the shape
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: filledBackgroundColor, width: 1),
          ),
        ),
      );

      // Use LayoutBuilder to decide how to size the button safely
      return LayoutBuilder(
        builder: (context, constraints) {
          // If explicit width given -> use it
          if (width != null) {
            return SizedBox(width: width, child: elevated);
          }

          // If parent provides a finite maxWidth -> fill it (full-width behavior)
          if (constraints.maxWidth.isFinite) {
            return SizedBox(width: constraints.maxWidth, child: elevated);
          }

          // Parent is unbounded (e.g., inside Row) -> return intrinsic button size so no layout error occurs.
          return elevated;
        },
      );
    }

    // TAG BUTTON (small pill)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tagBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tagBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: tagTextColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: tagTextColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

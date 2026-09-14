import 'package:flutter/material.dart';

/// Reusable interactive audio speaker button for Mundari pronunciation.
///
/// Designed for AyoVani teacher & student learning flows:
/// - Provides child-friendly tap feedback (ink ripple)
/// - Uses AyoVaani deep burgundy (#671D21) accent
/// - Compact icon size vertically aligned with text
/// - Pure interactive UI hook ready for backend audio playback integration
class MundariAudioButton extends StatelessWidget {
  const MundariAudioButton({
    super.key,
    required this.text,
    required this.onTap,
    this.iconSize = 22.0,
    this.color = const Color(0xFF671D21),
    this.tooltip,
  });

  /// The Mundari word or phrase associated with this audio button.
  final String text;

  /// Callback triggered when the speaker button is tapped.
  final VoidCallback onTap;

  /// Icon size in dp.
  final double iconSize;

  /// Theme accent color (defaults to AyoVaani deep burgundy).
  final Color color;

  /// Optional accessibility tooltip.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip ?? 'Play audio for $text',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkResponse(
          onTap: onTap,
          radius: iconSize * 0.9 + 6.0,
          containedInkWell: false,
          splashColor: color.withValues(alpha: 0.22),
          highlightColor: color.withValues(alpha: 0.10),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(
              Icons.volume_up_rounded,
              size: iconSize,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable component combining a Mundari text with an interactive speaker icon.
class MundariAudioText extends StatelessWidget {
  const MundariAudioText({
    super.key,
    required this.text,
    required this.onAudioTap,
    required this.style,
    this.iconSize = 22.0,
    this.iconColor = const Color(0xFF671D21),
    this.spacing = 6.0,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.flexible = false,
  });

  /// The Mundari text to display.
  final String text;

  /// Callback invoked when the speaker icon is pressed.
  final VoidCallback onAudioTap;

  /// Text style for the Devanagari text.
  final TextStyle style;

  /// Size of the speaker icon.
  final double iconSize;

  /// Color of the speaker icon.
  final Color iconColor;

  /// Spacing between speaker button and text.
  final double spacing;

  /// Main axis alignment of the row.
  final MainAxisAlignment mainAxisAlignment;

  /// Cross axis alignment (defaults to center for vertical alignment with text).
  final CrossAxisAlignment crossAxisAlignment;

  /// Whether the text should expand to take available space.
  final bool flexible;

  @override
  Widget build(BuildContext context) {
    final speaker = MundariAudioButton(
      text: text,
      onTap: onAudioTap,
      iconSize: iconSize,
      color: iconColor,
    );

    final textWidget = Text(
      text,
      textAlign: (mainAxisAlignment == MainAxisAlignment.center)
          ? TextAlign.center
          : TextAlign.start,
      style: style,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        speaker,
        SizedBox(width: spacing),
        Flexible(child: textWidget),
      ],
    );
  }
}

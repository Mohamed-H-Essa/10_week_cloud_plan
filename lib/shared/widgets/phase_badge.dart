import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/phase_colors.dart';

class PhaseBadge extends StatelessWidget {
  final String phase;
  final bool compact;

  const PhaseBadge({super.key, required this.phase, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final colors = phaseColorMap[phase];
    if (colors == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        phase,
        style: GoogleFonts.jetBrainsMono(
          fontSize: compact ? 9 : 11,
          fontWeight: FontWeight.w700,
          color: colors.text,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PhaseColors {
  final Color bg;
  final Color border;
  final Color text;

  const PhaseColors({
    required this.bg,
    required this.border,
    required this.text,
  });
}

const phaseColorMap = <String, PhaseColors>{
  'CONTAINERS': PhaseColors(
    bg: Color(0xFFEFF6FF),
    border: Color(0xFF0EA5E9),
    text: Color(0xFF0369A1),
  ),
  'INFRASTRUCTURE': PhaseColors(
    bg: Color(0xFFEEF2FF),
    border: Color(0xFF6366F1),
    text: Color(0xFF4338CA),
  ),
  'AUTOMATION': PhaseColors(
    bg: Color(0xFFFFFBEB),
    border: Color(0xFFF59E0B),
    text: Color(0xFFB45309),
  ),
  'CERT': PhaseColors(
    bg: Color(0xFFFEF2F2),
    border: Color(0xFFEF4444),
    text: Color(0xFFB91C1C),
  ),
  'CAPSTONE': PhaseColors(
    bg: Color(0xFFECFDF5),
    border: Color(0xFF10B981),
    text: Color(0xFF047857),
  ),
  'LAUNCH': PhaseColors(
    bg: Color(0xFFFDF4FF),
    border: Color(0xFFD946EF),
    text: Color(0xFFA21CAF),
  ),
};

const _phaseColorMapDark = <String, PhaseColors>{
  'CONTAINERS': PhaseColors(
    bg: Color(0xFF0C2D48),
    border: Color(0xFF38BDF8),
    text: Color(0xFF7DD3FC),
  ),
  'INFRASTRUCTURE': PhaseColors(
    bg: Color(0xFF1E1B4B),
    border: Color(0xFF818CF8),
    text: Color(0xFFA5B4FC),
  ),
  'AUTOMATION': PhaseColors(
    bg: Color(0xFF422006),
    border: Color(0xFFFBBF24),
    text: Color(0xFFFDE68A),
  ),
  'CERT': PhaseColors(
    bg: Color(0xFF450A0A),
    border: Color(0xFFF87171),
    text: Color(0xFFFCA5A5),
  ),
  'CAPSTONE': PhaseColors(
    bg: Color(0xFF052E16),
    border: Color(0xFF34D399),
    text: Color(0xFF6EE7B7),
  ),
  'LAUNCH': PhaseColors(
    bg: Color(0xFF3B0764),
    border: Color(0xFFE879F9),
    text: Color(0xFFF0ABFC),
  ),
};

/// Returns the appropriate PhaseColors for the given phase and brightness.
PhaseColors? getPhaseColors(String phase, Brightness brightness) {
  if (brightness == Brightness.dark) {
    return _phaseColorMapDark[phase];
  }
  return phaseColorMap[phase];
}

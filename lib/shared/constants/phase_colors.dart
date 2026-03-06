import 'package:flutter/material.dart';

class PhaseColors {
  final Color bg;
  final Color border;
  final Color text;

  const PhaseColors({required this.bg, required this.border, required this.text});
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

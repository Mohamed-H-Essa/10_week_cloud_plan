import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AnimatedNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<AnimatedNavBar> createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<AnimatedNavBar> with TickerProviderStateMixin {
  late final List<AnimationController> _scaleControllers;
  late final List<Animation<double>> _scaleAnimations;

  static const _items = [
    _NavItem(icon: Icons.bolt_outlined, activeIcon: Icons.bolt, label: 'Home'),
    _NavItem(icon: Icons.map_outlined, activeIcon: Icons.map, label: 'Plan'),
    _NavItem(icon: Icons.tune_outlined, activeIcon: Icons.tune, label: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _scaleControllers = List.generate(
      _items.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
        value: i == widget.currentIndex ? 1.0 : 0.0,
      ),
    );
    _scaleAnimations = _scaleControllers.map((c) {
      return CurvedAnimation(parent: c, curve: Curves.easeOutBack);
    }).toList();
  }

  @override
  void didUpdateWidget(AnimatedNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      for (int i = 0; i < _items.length; i++) {
        if (i == widget.currentIndex) {
          _scaleControllers[i].forward();
        } else {
          _scaleControllers[i].reverse();
        }
      }
    }
  }

  @override
  void dispose() {
    for (final c in _scaleControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            color: isDark
                ? Colors.black.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.85),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_items.length, (i) {
                    final item = _items[i];
                    final isActive = i == widget.currentIndex;

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (i != widget.currentIndex) {
                            HapticFeedback.lightImpact();
                            widget.onTap(i);
                          }
                        },
                        child: AnimatedBuilder(
                          listenable: _scaleAnimations[i],
                          builder: (context, child) {
                            final t = _scaleAnimations[i].value;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Indicator dot
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                  height: 3,
                                  width: isActive ? 20 : 0,
                                  margin: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                // Icon with scale bounce
                                Transform.scale(
                                  scale: 1.0 + (t * 0.15),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? primary.withValues(alpha: 0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isActive ? item.activeIcon : item.icon,
                                      size: 22,
                                      color: isActive
                                          ? primary
                                          : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                // Label
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                    color: isActive
                                        ? primary
                                        : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                                    letterSpacing: isActive ? 0.5 : 0,
                                  ),
                                  child: Text(item.label),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

// AnimatedBuilder that works with Animation<double>
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}

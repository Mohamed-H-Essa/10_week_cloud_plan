import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/reflection.dart';
import '../../providers/repositories_provider.dart';

class ReflectionSheet extends ConsumerStatefulWidget {
  final int weekNumber;
  const ReflectionSheet({super.key, required this.weekNumber});

  static Future<void> show(BuildContext context, int weekNumber) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ReflectionSheet(weekNumber: weekNumber),
    );
  }

  @override
  ConsumerState<ReflectionSheet> createState() => _ReflectionSheetState();
}

class _ReflectionSheetState extends ConsumerState<ReflectionSheet> {
  late TextEditingController _wentWellController;
  late TextEditingController _toImproveController;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(reflectionRepoProvider).getForWeek(widget.weekNumber);
    _wentWellController = TextEditingController(text: existing?.wentWell ?? '');
    _toImproveController = TextEditingController(text: existing?.toImprove ?? '');
  }

  @override
  void dispose() {
    _wentWellController.dispose();
    _toImproveController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(reflectionRepoProvider).save(Reflection(
      weekNumber: widget.weekNumber,
      wentWell: _wentWellController.text,
      toImprove: _toImproveController.text,
      createdAt: DateTime.now(),
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Week ${widget.weekNumber} Reflection',
            style: GoogleFonts.jetBrainsMono(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Text('What went well?',
              style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green.shade700)),
          const SizedBox(height: 8),
          TextField(
            controller: _wentWellController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Things that worked, wins, breakthroughs...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 16),
          Text('What to improve?',
              style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.orange.shade700)),
          const SizedBox(height: 8),
          TextField(
            controller: _toImproveController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Blockers, things to do differently next time...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: const Text('Save Reflection'),
            ),
          ),
        ],
      ),
    );
  }
}
